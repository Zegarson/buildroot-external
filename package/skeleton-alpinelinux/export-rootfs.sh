for d in bin etc lib root sbin usr; do tar c "$d" | tar x -C /alpine-rootfs; done
for dir in dev proc run sys var; do mkdir /alpine-rootfs/${dir}; done