Copy image_source.jpg to create 300 source files, e.g.:

```bash
for i in `seq 1 300` ; do
    newf=$( printf "img_%03d.jpg" $i )
    cp image_source.jpg $newf
done
```
