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
        path = dstdir substr($2, 4);
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
            tag_target[t, tag[t]++] = path;
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

  for (t in tag) {
    printf ".PHONY: %s\n", t;
    printf "%s: \\\n", t;
    for (i = 0; i < tag[t]; i++)
      printf " %s \\\n", tag_target[t, i];
    print "";
    delete tag_list[t];
  }

  for (t in tag_list) {
    printf ".PHONY: %s\n", t;
    printf "%s:\n\n", t
  }
}
