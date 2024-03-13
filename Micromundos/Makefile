etcher:
	
	nasm -fbin boot.asm -o boot.bin
	nasm -fbin game.asm -o game.bin

	cat boot.bin game.bin > bootgame.bin

image:

	dd if=/dev/zero of=bootgame.img bs=512 count=2880
	
	nasm -fbin boot2.asm -o boot2.bin
	nasm -fbin game.asm -o game.bin

	cat boot2.bin game.bin > bootgame.img

run:
	dd if=/dev/zero of=bootgame.img bs=512 count=2880
	
	nasm -fbin boot2.asm -o boot2.bin
	nasm -fbin game.asm -o game.bin

	cat boot2.bin game.bin > bootgame.bin
	
	qemu-system-i386 bootgame.bin 
	


