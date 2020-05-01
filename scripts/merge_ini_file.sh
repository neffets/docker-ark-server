#!/usr/bin/env bash

echo "#--------------------------------------------------------#"
echo "# Merging $1"
echo "# Into $2"
echo "#--------------------------------------------------------#"
IFS=
NEW_CONTENTS=$(awk '/^$/{
   next
}
/^\[.*\]$/{
   hdr = $0
   next
}
a[hdr] != "" {
   a[hdr] = a[hdr] ORS $0
   next
}
{
   a[hdr] = $0
   seq[++n] = hdr
}
END {
   for (i=1; i<=n; i++)
      print seq[i] ORS a[seq[i]] (i<n ? ORS : "")
}' $1 $2)

echo -n ${NEW_CONTENTS}