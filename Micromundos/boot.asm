; Boot sector for loading an assembly program from USB

org 0x7C00
bits 16

%define SECTORS_TO_READ 0xA ; Number of sectors to read from disk

jmp short start
nop

; Boot Parameter Block
OEMname db "mkfs.fat"	; Disk label
BytesPerSector dw 512 ; Bytes per sector
SectorsPerCluster db 1 ; Sectors per cluster
ReservedSectors dw 1 ; Reserved sectors for boot record
NumFATs db 2 ; Number of copies of the FAT
RootDirEntries dw 224 ; Number of entries in root directory
TotalSectors dw 2880 ; Total number of sectors
MediaByte db 0xF0 ; Media descriptor byte
SectorsPerFAT dw 9 ; Sectors per FAT
SectorsPerTrack dw 63 ; Sectors per track
NumHeads dw 2 ; Number of heads
HiddenSectors dd 0 ; Number of hidden sectors
LargeSectors dd 0 ; Number of LBA sectors
DriveNumber db 0 ; Drive number
Signature db 0x41 ; Drive signature
VolumeID dd 0 ;
VolumeLabel db "Operativos " ; Volume label (11 characters)
FileSystem db "FAT12   " ; File system type

start:
; Initialize registers
cli
xor ax, ax
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax
mov sp, 0x7C00 ; Set stack pointer
sti


; Reset disk system
mov ah, 0
int 0x13     ; BIOS disk I/O
jc errorLoop

; Read from disk and write to memory
mov bx, 0x8000         ; Address to write the program to
mov al, SECTORS_TO_READ ; Number of sectors to read
mov ch, 0              ; Cylinder
mov dh, 0              ; Head
mov cl, 2              ; Sector
mov ah, 2              ; AH=2: read disk sectors
int 0x13               ; BIOS disk I/O
jmp 0x8000
jc errorLoop           ; Jump to error handling if the BIOS returns an error





errorLoop:
; Print error message
mov si, errormsg
mov bh, 0x00 ; Page 0
mov bl, 0x07 ; Text attribute
mov ah, 0x0E ; AH=0x0E: BIOS print character
.printloop:
lodsb ; Load a byte from SI into AL
sub al, 0 ; Subtract 0 from AL to check for null terminator
jz end ; Jump to end if null terminator is found
int 0x10 ; Print character in AL using BIOS video services
jmp .printloop

end:
jmp $ ; Infinite loop

errormsg db "Error booting...", 0

times (510-($-$$)) nop ; Pad with zeros until byte 510
db 0x55 ; Signature byte 1
db 0xAA ; Signature byte 2