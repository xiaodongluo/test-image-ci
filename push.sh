t=$(date "+%Y-%m-%d %H:%M:%S")
sed "2c MAINTAINER $t" input > Dockerfile
git add Dockerfile
git commit -m "commit img-test $t"
git push
