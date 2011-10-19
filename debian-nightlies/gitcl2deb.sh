#!/usr/bin/env python

# Produce a Debian changelog grouped by committer from a git log
# Feed it with git log A..B --pretty=format:"[ %an ]%n>%s"

import sys
import collections
import re


def main():
    groups = collections.defaultdict(list)
    g = None
    for line in sys.stdin:
        if line.startswith('['):
            g = line.strip()
        elif line.startswith('>'):
            commit = line[1:]
            commit = re.sub(r'^\s*[*\-+>]\s+', '', commit)
            groups[g].append(commit.strip())

    for author, commits in groups.items():
        print "  %s" % author
        for commit in commits:
            print "  * %s" % commit

if __name__ == "__main__":
    main()
