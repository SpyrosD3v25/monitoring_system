#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <fcntl.h>
#include <unistd.h>
#include <ctype.h>

#define BUFFER_SIZE 4096

// Structure to pass data to/from threads
typedef struct
{
  char           *filename;
  int             line_count;
  int             error_count;
  int             success;
} thread_data_t;

// Thread function to analyze a log file
void           *
analyze_file (void *arg)
{
  thread_data_t  *data = (thread_data_t *) arg;

  int             fd = open (data->filename, O_RDONLY);
  if (fd == -1)
    {
      fprintf (stderr, "Error opening file: %s\n", data->filename);
      data->success = 0;
      pthread_exit (NULL);
    }

  data->line_count = 0;
  data->error_count = 0;
  data->success = 1;

  char            buffer[BUFFER_SIZE];
  char            line_buffer[1024];
  int             line_pos = 0;
  ssize_t         bytes_read;

  while ((bytes_read = read (fd, buffer, BUFFER_SIZE)) > 0)
    {
      for (ssize_t i = 0; i < bytes_read; i++)
	{
	  if (buffer[i] == '\n')
	    {
	      line_buffer[line_pos] = '\0';
	      data->line_count++;

	      // Check for ERROR
	      if (strstr (line_buffer, "ERROR") != NULL)
		{
		  data->error_count++;
		}

	      line_pos = 0;
	    }
	  else if (line_pos < 1023)
	    {
	      line_buffer[line_pos++] = buffer[i];
	    }
	}
    }

  // Handle last line if it doesn't end with newline
  if (line_pos > 0)
    {
      line_buffer[line_pos] = '\0';
      data->line_count++;

      if (strstr (line_buffer, "ERROR") != NULL)
	{
	  data->error_count++;
	}
    }

  close (fd);
  pthread_exit (NULL);
}

int
main (int argc, char *argv[])
{
  if (argc < 2)
    {
      fprintf (stderr, "Usage: %s <logfile1> [logfile2] ...\n", argv[0]);
      return 1;
    }

  int             num_files = argc - 1;
  pthread_t      *threads = malloc (num_files * sizeof (pthread_t));
  thread_data_t  *thread_data = malloc (num_files * sizeof (thread_data_t));

  if (!threads || !thread_data)
    {
      fprintf (stderr, "Memory allocation failed\n");
      return 1;
    }

  // Create threads
  printf ("Starting parallel analysis of %d files...\n\n", num_files);

  for (int i = 0; i < num_files; i++)
    {
      thread_data[i].filename = argv[i + 1];
      thread_data[i].line_count = 0;
      thread_data[i].error_count = 0;
      thread_data[i].success = 0;

      if (pthread_create (&threads[i], NULL, analyze_file, &thread_data[i]) !=
	  0)
	{
	  fprintf (stderr, "Error creating thread for %s\n", argv[i + 1]);
	  thread_data[i].success = 0;
	}
    }

  // Wait for all threads to complete
  for (int i = 0; i < num_files; i++)
    {
      pthread_join (threads[i], NULL);
    }

  // Print individual results
  printf ("=== Individual File Results ===\n");
  int             total_lines = 0;
  int             total_errors = 0;

  for (int i = 0; i < num_files; i++)
    {
      if (thread_data[i].success)
	{
	  printf ("File: %s | Lines: %d | Errors: %d\n",
		  thread_data[i].filename,
		  thread_data[i].line_count, thread_data[i].error_count);

	  total_lines += thread_data[i].line_count;
	  total_errors += thread_data[i].error_count;
	}
      else
	{
	  printf ("File: %s | FAILED TO PROCESS\n", thread_data[i].filename);
	}
    }

  // Print totals
  printf ("\n=== Totals ===\n");
  printf ("TOTAL LINES: %d\n", total_lines);
  printf ("TOTAL ERRORS: %d\n", total_errors);

  // Cleanup
  free (threads);
  free (thread_data);

  return 0;
}
