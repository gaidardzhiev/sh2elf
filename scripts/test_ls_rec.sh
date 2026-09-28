/bin/rm -rf ls_r
/bin/mkdir -p ls_r/top/sub1/deep ls_r/top/sub2 ls_r/other
cd ls_r
/usr/bin/touch top/f1 top/sub1/f2 top/sub1/deep/f3 top/sub2/.h other/o1
ln -s .. top/sub2/up
ls -R top
ls -Ra top/sub2
ls -R top other
ls -R -1 top/sub1
ls top other top/f1
ls -d top other
ls -RL top/sub2
echo "rc=$?"
ls -R nofile top/sub1/deep
echo "rc=$?"
cd ..
/bin/rm -rf ls_r
