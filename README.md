# JRPG

## Control
Move: WASD<br />
Interact: Enter<br />
Camera: Left/Right Arrow<br />
Attack: JK<br />

## Cara Buat World
1. Ke folder `res://tools/`
2. Buka file script `res://tools/world_generator.gd`
3. Edit `new_world_name`
4. Klik kanan file script
5. Klik `run`
6. Ke folder `res://worlds/`
7. Cari folder worldnya
8. Klik file scene worldnya yang berakhiran `.scn`
9. Ke tab kanan (Inspector)
10. Edit nama lokasi

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
11. Ganti `Warp Type` bila perlu
12. Ke scene world kedua
13. Drag and drop `res://points/WarpPoint/warp_point.scn` ke node `WarpPoints` sebagai children di scene world kedua
14. Ke tab `3D` 
15. Drag and drop lokasi warp pointnya
16. Rename warp point world kedua ke warp point yang digunakan pada kolom `Target Point Name` di warp point world pertama
17. Ceklis `Editable Children`
18. Klik node warp point world keduanya
19. Ke tab kanan
20. Ganti `Target World Path` ke path file world pertama
21. Ganti `Target Point Name` ke nama warp point di world pertama
22. Ganti `Warp Type` bila perlu
23. Kamu bisa memindahkan posisi `SpawnPosition` karena sudah meceklis `Editable Children`
24. Save kedua world

## Cara Mengedit World
1. Klik scene world
2. Klik node `Terrain3D`
3. Buka https://www.youtube.com/watch?v=ejlD8cM9kk4
4. Save world

## Cara Mengedit Terrain3D Meshes/Texture
1. Klik scene `res://worlds/BaseWorld/base_world.scn`
2. Klik node `Terrain3D`
3. Edit seperlunya
4. Save world
