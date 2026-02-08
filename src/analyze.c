#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <ctype.h>

#define MAX_LINE_LENGTH 1024

#define EXIT_OK 0
#define EXIT_CANT_OPEN 1
#define EXIT_EMPTY 2

typedef struct
{
  unsigned long   line_count;
  unsigned long   error_count;
  unsigned long   number_count;
} FileStats;

int
has_error (const char *line)
{
  return strstr (line, "ERROR") != NULL;
}

int
has_number (const char *line)
{
  while (*line)
    {
      if (isdigit ((unsigned char) *line))
	{
	  return 1;
	}
      line++;
    }
  return 0;
}

int
analyze_file (const char *filename, FileStats *stats)
{
  int             fd;
  FILE           *file;
  char            line[MAX_LINE_LENGTH];

  memset (stats, 0, sizeof (FileStats));

  fd = open (filename, O_RDONLY);
  if (fd == -1)
    {
      /* Use perror to show what went wrong */
      perror ("ERROR: Failed to open file");
      fprintf (stderr, "File: %s\n", filename);
      fprintf (stderr, "Error code: %d (%s)\n", errno, strerror (errno));
      return EXIT_CANT_OPEN;
    }

  file = fdopen (fd, "r");
  if (file == NULL)
    {
      perror ("ERROR: Failed to create file stream");
      close (fd);
      return EXIT_CANT_OPEN;
    }

  while (fgets (line, sizeof (line), file) != NULL)
    {
      stats->line_count++;

      if (has_error (line))
	{
	  stats->error_count++;
	}

      if (has_number (line))
	{
	  stats->number_count++;
	}
    }

  if (ferror (file))
    {
      perror ("ERROR: Failed to read file");
      fclose (file);
      return EXIT_CANT_OPEN;
    }

  fclose (file);

  if (stats->line_count == 0)
    {
      fprintf (stderr, "WARNING: File is empty: %s\n", filename);
      return EXIT_EMPTY;
    }

  return EXIT_OK;
}

int
main (int argc, char *argv[])
{
  FileStats       stats;
  int             result;

  if (argc != 2)
    {
      fprintf (stderr, "Usage: %s <logfile>\n", argv[0]);
      fprintf (stderr, "Example: %s /path/to/system.log\n", argv[0]);
      return EXIT_CANT_OPEN;
    }

  result = analyze_file (argv[1], &stats);

  if (result == EXIT_OK || result == EXIT_EMPTY)
    {
      printf ("=== Log Analysis Results ===\n");
      printf ("File: %s\n", argv[1]);
      printf ("Total lines: %lu\n", stats.line_count);
      printf ("Lines with ERROR: %lu\n", stats.error_count);
      printf ("Lines with numbers: %lu\n", stats.number_count);
      printf ("===========================\n");
    }

  return result;
}
