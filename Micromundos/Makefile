PHONY: all

all:
	dd if=/dev/zero of=bootgame.img bs=512 count=2880
	
	nasm -fbin boot.asm -o boot.bin
	nasm -fbin game.asm -o game.bin
	
	dd if=boot.bin of=bootgame.img bs=512 seek=0 count=1 conv=notrunc
	dd if=game.bin of=bootgame.img bs=512 seek=1 count=1 conv=notrunc

run:
	dd if=/dev/zero of=bootgame.img bs=512 count=2880
	
	nasm -fbin boot.asm -o boot.bin
	nasm -fbin game.asm -o game.bin
	
	cat boot.bin game.bin > program.bin
	qemu-system-i386 program.bin
	
check:
	ls -l /dev/disk/by-id/*usb*
	
burn:
	sudo dd if=/dev/zero of=/dev/sdb count=2880 bs=512
	sudo dd if=bootgame.img of=/dev/sdb count=2880 bs=512

clean:
	rm *.bin
