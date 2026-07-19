# JRPG

## Control
Move: WASD
Interact: Enter
Camera: Left/Right Arrow
Attack: JK

## Cara Buat World
1. Ke folder `res://tools/`
2. Buka file script `res://tools/world_generator.gd`
3. Edit `new_world_name`
4. Klik kanan file script
5. Klik `run`

## Cara Buat Save Point
1. Drag and drop `res://points/SavePoint/save_point.scn` ke node `SavePoints` sebagai children di scene world
2. Ke tab `3D`
3. Drag and drop lokasi save pointnya
4. Rename save point jika perlu
5. Save world

## Cara Buat Warp Point
1. Drag and drop `res://points/WarpPoint/warp_point.scn` ke node `WarpPoints` sebagai children di scene world pertama
2. Ke tab `3D` 
3. Drag and drop lokasi warp pointnya
4. Rename warp point ke warp point spesifik
5. Klik kanan node warp point tersebut
6. Ceklis `Editable Children`
7. Klik node warp pointnya
8. Ke tab kanan
9. Ganti `Target World Path` ke path file world kedua
10. Ganti `Target Point Name` ke nama warp point di world kedua
11. Ganti `Location Name`
12. Ganti `Warp Type` bila perlu
13. Ke scene world kedua
14. Drag and drop `res://points/WarpPoint/warp_point.scn` ke node `WarpPoints` sebagai children di scene world kedua
15. Ke tab `3D` 
16. Drag and drop lokasi warp pointnya
17. Rename warp point world kedua ke warp point yang digunakan pada kolom `Target Point Name` di warp point world pertama
18. Ceklis `Editable Children`
19. Klik node warp point world keduanya
20. Ke tab kanan
21. Ganti `Target World Path` ke path file world pertama
22. Ganti `Target Point Name` ke nama warp point di world pertama
23. Ganti `Location Name`
24. Ganti `Warp Type` bila perlu
25. Save kedua world

## Cara Mengedit World
1. Klik scene world
2. Klik node `Terrain3D`
3. Buka https://www.youtube.com/watch?v=ejlD8cM9kk4
4. Save world
