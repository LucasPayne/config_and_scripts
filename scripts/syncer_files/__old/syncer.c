/*--------------------------------------------------------------------------------
    Syncer
    ------
    Generate configurations for programs based on a mapping from a letter sequence
    to a file or directory name.
--------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int getline(char *buf, const int size, FILE *file)
{
    while (1) {
        if (fgets(buf, size, file) == NULL) {
            return EOF;
        }
        char *p = buf;
        while (isspace(*p)) p++;
        // If the line is empty or commented, keep going until EOF or a wanted line is found.
        if (*p != '\0' && *p != '#') {
            break;
        }
    }
    return strlen(buf);
}
void assertline(char *buf, const int size, FILE *file, const char *cmp_to)
{
    if (getline(buf, size, file) == EOF || strcmp(buf, cmp_to) != 0) {
        fprintf(stderr, "Syncer error: Expected line \"%s\".\n");
        exit(EXIT_FAILURE);
    }
}

static void error(const char *error_string)
{
    fprintf(stderr, "Syncer error: %s\n", error_string);
    exit(EXIT_FAILURE);
}

int main(int argc, char **argv)
{


    if (argc != 2) {
        fprintf(stderr, "Syncer error: give good args.\n");
        exit(EXIT_FAILURE);
    }
    char *filename = argv[1];
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        fprintf(stderr, "Syncer error: Failed to open file \"%s\".\n", filename);
        exit(EXIT_FAILURE);
    }

    const int n = 4096;
    char buf[n];

    assertline(buf, n, file, "directories");
    assertline(buf, n, file, "-----------");
    while (1) {
        if (getline(buf, n, file) == EOF) error("Not finished.");
        char *space = strchr(buf, ' ');
        if (space == NULL) error("Malformed directory entry.");
    }


}



