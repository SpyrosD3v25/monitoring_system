#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <errno.h>

#define MAX_LINE_LENGTH 1024
#define MAX_FILES 100

typedef struct
{
  char            filename[256];
  unsigned long   line_count;
  unsigned long   error_count;
  int             status;	/* 0=ok, 1=error, 2=empty */
  pthread_t       thread;
} ThreadData;

typedef struct
{
  unsigned long   total_lines;
  unsigned long   total_errors;
  int             files_ok;
  int             files_failed;
} Summary;

static int
has_error (const char *line)
{
  return strstr (line, "ERROR") != NULL;
}

void           *
analyze_thread (void *arg)
{
  ThreadData     *data = (ThreadData *) arg;
  FILE           *file;
  char            line[MAX_LINE_LENGTH];

  data->line_count = 0;
  data->error_count = 0;
  data->status = 0;

  file = fopen (data->filename, "r");
  if (file == NULL)
    {
      fprintf (stderr, "[Thread %lu] ERROR: Cannot open %s: %s\n",
	       (unsigned long) pthread_self (), data->filename,
	       strerror (errno));
      data->status = 1;
      return NULL;
    }

  while (fgets (line, sizeof (line), file) != NULL)
    {
      data->line_count++;

      if (has_error (line))
	{
	  data->error_count++;
	}
    }

  if (ferror (file))
    {
      fprintf (stderr, "[Thread %lu] ERROR: Read error in %s\n",
	       (unsigned long) pthread_self (), data->filename);
      data->status = 1;
    }

  fclose (file);

  if (data->line_count == 0)
    {
      data->status = 2;
    }

  return NULL;
}

int
main (int argc, char *argv[])
{
  ThreadData      threads[MAX_FILES];
  Summary         summary = { 0 };
  int             num_files;
  int             i;
  int             ret;

  if (argc < 2)
    {
      fprintf (stderr, "Usage: %s <logfile1> [logfile2] [...]\n", argv[0]);
      fprintf (stderr, "Example: %s system.log network.log security.log\n",
	       argv[0]);
      return EXIT_FAILURE;
    }

  num_files = argc - 1;
  if (num_files > MAX_FILES)
    {
      fprintf (stderr, "ERROR: Too many files (max %d)\n", MAX_FILES);
      return EXIT_FAILURE;
    }

  printf ("=== Parallel Log Analysis ===\n");
  printf ("Processing %d file(s) with threads...\n\n", num_files);

  for (i = 0; i < num_files; i++)
    {
      strncpy (threads[i].filename, argv[i + 1],
	       sizeof (threads[i].filename) - 1);
      threads[i].filename[sizeof (threads[i].filename) - 1] = '\0';

      ret =
	pthread_create (&threads[i].thread, NULL, analyze_thread,
			&threads[i]);
      if (ret != 0)
	{
	  fprintf (stderr, "ERROR: pthread_create failed for %s: %s\n",
		   threads[i].filename, strerror (ret));
	  return EXIT_FAILURE;
	}
    }

  for (i = 0; i < num_files; i++)
    {
      ret = pthread_join (threads[i].thread, NULL);
      if (ret != 0)
	{
	  fprintf (stderr, "WARNING: pthread_join failed: %s\n",
		   strerror (ret));
	}
    }

  printf ("=== Individual File Results ===\n");
  for (i = 0; i < num_files; i++)
    {
      printf ("File: %-20s | Lines: %6lu | Errors: %6lu",
	      threads[i].filename,
	      threads[i].line_count, threads[i].error_count);

      if (threads[i].status == 1)
	{
	  printf (" [FAILED]");
	  summary.files_failed++;
	}
      else if (threads[i].status == 2)
	{
	  printf (" [EMPTY]");
	}
      else
	{
	  summary.files_ok++;
	}
      printf ("\n");

      summary.total_lines += threads[i].line_count;
      summary.total_errors += threads[i].error_count;
    }

  printf ("\n=== Global Summary ===\n");
  printf ("TOTAL LINES:        %lu\n", summary.total_lines);
  printf ("TOTAL ERRORS:       %lu\n", summary.total_errors);
  printf ("Files Processed:    %d\n", summary.files_ok);
  printf ("Files Failed:       %d\n", summary.files_failed);
  printf ("=====================\n");

  return (summary.files_failed > 0) ? EXIT_FAILURE : EXIT_SUCCESS;
}
