.PHONY: all


all:

	dd if=/dev/zero of=bootgame.img bs=512 count=2880


	nasm -f bin boot.asm -o boot.bin
	nasm -f bin game.asm -o game.bin

	dd if=boot.bin of=bootgame.img bs=512 seek=0 count=1 conv=notrunc
	dd if=game.bin of=bootgame.img bs=512 seek=1 count=1 conv=notrunc

run:

	qemu-system-i386 -drive format=raw,file=bootgame.img -monitor stdio 
	
	
