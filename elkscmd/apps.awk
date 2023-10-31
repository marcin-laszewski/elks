#!/usr/bin/awk -f

BEGIN {
  cp_n = 0;
  ln_n = 0;
  tag_n = 0;

  n = split(tags, tab);
  print "tags_n = " n > "/dev/stderr";
  for (i = 1; i <= n; i++)
    tag_list[tab[i]] = "";
  delete tab;
  for (t in tag_list)
    print "\t" t > "/dev/stderr";
}

function basename(path)
{
  gsub("^.*/", "", path);
  return path;
}

{
  gsub("#.*$", "");
  #print NF "\t" $0;
  if (NF > 0) {
    file = $1;
    if (NF > 1) {
      if (substr($2, 1, 3) == ":::") {
        path = dstdir "bin/" substr($2, 4);
        link = basename(file);
        i = 3;
      }
      else if (substr($2, 1, 2) == "::") {
        path = dstdir substr($2, 3);
        link = "";
        i = 3;
      }
      else {
        path = dstdir "bin/" basename(file);
        link = "";
        i = 2;
      }

      is_included = 0;
      while (i <= NF) {
        if (substr($i, 1, 1) == ":") {
          t = substr($i, 2);
          if (t in tag_list) {
            is_included = 1;
            if (!(t in tag))
              tag[t] = 0;
            tag_build[t, tag[t]] = srcdir file;
            tag_install[t, tag[t]] = path;
            tag[t]++
          }
        }
        i++;
      }

      if (is_included) {
        if (link == "") {
          printf "%s:\t%s%s\n", path, srcdir, file;
          cp[cp_n++] = path;
        }
        else {
          printf "%s:\tLINK=%s\n", path, link;
          ln[ln_n++] = path;
        }
      }
    }
  }
}

function create_targets(name, prefix, tag, tag_targets,	t, i)
{
  printf "#--- %s\n", name;

  for (t in tag) {
    printf ".PHONY: %s%s\n",prefix, t;
    printf "%s%s: \\\n", prefix, t;
    for (i = 0; i < tag[t]; i++)
      printf " %s \\\n", tag_targets[t, i];
    print "";
  }
}

END {
  sep = "\n";
  for (i in cp) {
    printf "%s%s", sep, cp[i];
    sep = " \\\n";
  }
  print ":";
  print "\tmkdir -p $(dir $@)"
  print "\tcp $< $@";

  sep = "\n";
  for (i in ln) {
    printf "%s%s", sep, ln[i];
    sep = " \\\n";
  }
  print ":";
  print "\tmkdir -p $(dir $@)"
  print "\tln -s $(LINK) $@";
  print "";

  create_targets("build", "", tag, tag_build);
##  print "#--- build"
##  for (t in tag) {
##    printf ".PHONY: %s\n", t;
##    printf "%s: \\\n", t;
##    for (i = 0; i < tag[t]; i++)
##      printf " %s \\\n", tag_build[t, i];
##    print "";
##  }

  create_targets("install", "install-", tag, tag_install);
##  print "--- install"
##  for (t in tag) {
##    printf ".PHONY: install-%s\n", t;
##    printf "install-%s: \\\n", t;
##    for (i = 0; i < tag[t]; i++)
##      printf " %s \\\n", tag_install[t, i];
##    print "";
##    delete tag_list[t];
##  }

  for (t in tag)
    delete tag_list[t];

  print "#2------"
  for (t in tag_list) {
    printf ".PHONY: %s\n", t;
    printf "%s:\n\n", t
  }
}
