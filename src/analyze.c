#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <ctype.h>

#define BUFFER_SIZE 4096

int
main (int argc, char *argv[])
{
  if (argc != 2)
    {
      fprintf (stderr, "Usage: %s <logfile>\n", argv[0]);
      return 1;
    }

  const char     *filename = argv[1];
  int             fd = open (filename, O_RDONLY);

  if (fd == -1)
    {
      perror ("Error opening file");
      fprintf (stderr, "Failed to open: %s (errno: %d)\n", filename, errno);
      return 1;
    }

  char            buffer[BUFFER_SIZE];
  int             line_count = 0;
  int             error_count = 0;
  int             number_count = 0;

  ssize_t         bytes_read;
  char            line_buffer[1024];
  int             line_pos = 0;

  while ((bytes_read = read (fd, buffer, BUFFER_SIZE)) > 0)
    {
      for (ssize_t i = 0; i < bytes_read; i++)
	{
	  if (buffer[i] == '\n')
	    {
	      line_buffer[line_pos] = '\0';
	      line_count++;

	      // Check for ERROR
	      if (strstr (line_buffer, "ERROR") != NULL)
		{
		  error_count++;
		}

	      // Check for numbers
	      for (int j = 0; j < line_pos; j++)
		{
		  if (isdigit (line_buffer[j]))
		    {
		      number_count++;
		      break;
		    }
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
      line_count++;

      if (strstr (line_buffer, "ERROR") != NULL)
	{
	  error_count++;
	}

      for (int j = 0; j < line_pos; j++)
	{
	  if (isdigit (line_buffer[j]))
	    {
	      number_count++;
	      break;
	    }
	}
    }

  close (fd);

  if (line_count == 0)
    {
      fprintf (stderr, "File is empty: %s\n", filename);
      return 2;
    }

  printf ("Analysis of %s:\n", filename);
  printf ("  Total lines: %d\n", line_count);
  printf ("  Lines with ERROR: %d\n", error_count);
  printf ("  Lines with numbers: %d\n", number_count);

  return 0;
}
