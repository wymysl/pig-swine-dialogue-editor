import struct
import random

def encode_cell(x, y, source_id, atlas_x, atlas_y, alternative_tile=0):
    coord_int = (x & 0xFFFF) | ((y & 0xFFFF) << 16)
    source_int = (source_id & 0xFFFF) | ((alternative_tile & 0xFFFF) << 16)
    atlas_int = (atlas_x & 0xFFFF) | ((atlas_y & 0xFFFF) << 16)
    def to_signed(v):
        return struct.unpack("i", struct.pack("I", v))[0]
    return f"{to_signed(coord_int)}, {to_signed(source_int)}, {to_signed(atlas_int)}"

cells = []
# Floor 24x16
for x in range(24):
    for y in range(16):
        # 6 variants of floor in 0:0, 0:1, 1:0, 1:1, 2:0, 2:1
        atlas_x = random.randint(0, 2)
        atlas_y = random.randint(0, 1)
        cells.append(encode_cell(x, y, 0, atlas_x, atlas_y))

# Walls (perimeter)
for x in range(24):
    atlas_x = random.randint(0, 5)
    cells.append(encode_cell(x, 0, 1, atlas_x, 0))
    atlas_x = random.randint(0, 5)
    cells.append(encode_cell(x, 15, 1, atlas_x, 0))

for y in range(1, 15):
    atlas_x = random.randint(0, 5)
    cells.append(encode_cell(0, y, 1, atlas_x, 0))
    atlas_x = random.randint(0, 5)
    cells.append(encode_cell(23, y, 1, atlas_x, 0))

tile_data = ", ".join(cells)

tscn_content = f"""[gd_scene load_steps=29 format=3 uid="uid://pig_swine_office_001"]

[ext_resource type="Script" path="res://scripts/actors/player.gd" id="1_player"]
[ext_resource type="Script" path="res://scripts/actors/door.gd" id="2_door"]
[ext_resource type="Script" path="res://scripts/actors/npc.gd" id="3_npc"]
[ext_resource type="SpriteFrames" path="res://art/sprites/cula/cula_sprite_frames.tres" id="4_cula_frames"]
[ext_resource type="Script" path="res://scripts/actors/pickup.gd" id="8_qhjoq"]
[ext_resource type="Script" path="res://scripts/actors/behind_desk_zone.gd" id="11_behind_desk"]
[ext_resource type="Script" path="res://scripts/actors/pig_idle_zone.gd" id="12_pig_idle"]
[ext_resource type="AudioStream" path="res://audio/music/office.mp3" id="13_music"]
[ext_resource type="Script" path="res://scripts/actors/minigame_trigger.gd" id="14_minigame_trigger"]
[ext_resource type="Texture2D" path="res://art/props/receptionL.png" id="16_receptionL"]
[ext_resource type="SpriteFrames" path="res://art/sprites/asia/asia_sprite_frames.tres" id="17_asia_frames"]
[ext_resource type="Script" path="res://scripts/actors/asia.gd" id="18_asia_gd"]
[ext_resource type="Texture2D" path="res://art/props/office/fern.png" id="p01_fern"]
[ext_resource type="Texture2D" path="res://art/props/office/wall_calendar.png" id="p02_calendar"]
[ext_resource type="Texture2D" path="res://art/props/office/chair_pig.png" id="p03_chair"]
[ext_resource type="Texture2D" path="res://art/props/office/coffee_machine.png" id="p04_coffee"]
[ext_resource type="Texture2D" path="res://art/props/office/printer.png" id="p05_printer"]
[ext_resource type="Texture2D" path="res://art/props/office/desk_pig.png" id="p06_desk_pig"]
[ext_resource type="Texture2D" path="res://art/props/office/desk_swine.png" id="p07_desk_swine"]
[ext_resource type="Texture2D" path="res://art/props/office/desk_murrow.png" id="p08_desk_murrow"]
[ext_resource type="Texture2D" path="res://art/props/office/desk_rak.png" id="p09_desk_rak"]
[ext_resource type="Texture2D" path="res://art/props/office/desk_wymysl.png" id="p10_desk_wymysl"]
[ext_resource type="Texture2D" path="res://art/props/office/desk_kula.png" id="p11_desk_kula"]
[ext_resource type="Texture2D" path="res://art/props/office/bookshelf.png" id="p12_bookshelf"]
[ext_resource type="Texture2D" path="res://art/props/office/archive_boxes.png" id="p13_archive"]
[ext_resource type="Texture2D" path="res://art/props/office/office_door.png" id="p14_door"]
[ext_resource type="Texture2D" path="res://art/props/office/certificate.png" id="p15_cert"]
[ext_resource type="Texture2D" path="res://art/props/office/wall_clock.png" id="p16_clock"]
[ext_resource type="Texture2D" path="res://art/props/office/desk_lamp.png" id="p17_lamp"]
[ext_resource type="Texture2D" path="res://art/props/office/trash_bin.png" id="p18_trash"]
[ext_resource type="Texture2D" path="res://art/props/office/window.png" id="p19_window"]
[ext_resource type="Texture2D" path="res://art/props/office/coffee_mug.png" id="p20_mug"]
[ext_resource type="PackedScene" uid="uid://061c39c464a24" path="res://scenes/components/npc_walking_canon.tscn" id="1_canon"]
[ext_resource type="SpriteFrames" uid="uid://53f0277bdb814" path="res://art/sprites/mr_pig/mr_pig_sprite_frames.tres" id="frames_mr_pig"]
[ext_resource type="SpriteFrames" uid="uid://a8618e2f94b54" path="res://art/sprites/murrow/murrow_sprite_frames.tres" id="frames_murrow"]
[ext_resource type="TileSet" path="res://art/tilesets/office_tileset.tres" id="tileset_office"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_door_horiz"]
size = Vector2(48, 16)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_player"]
size = Vector2(24, 24)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_npc"]
size = Vector2(52, 56)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_pigzone"]
size = Vector2(144, 128)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_deskfront_bottom"]
size = Vector2(100, 60)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_deskfront_left"]
size = Vector2(50, 150)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_behinddsk"]
size = Vector2(108, 120)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_reception_desk_bottom"]
size = Vector2(94, 53)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_reception_desk_left"]
size = Vector2(45, 143)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_coffee"]
size = Vector2(48, 48)

[node name="PigSwineOffice" type="Node2D"]
y_sort_enabled = true

[node name="Music" type="AudioStreamPlayer" parent="."]
stream = ExtResource("13_music")
autoplay = true
process_mode = 3

[node name="TileMap" type="TileMap" parent="."]
y_sort_enabled = true
tile_set = ExtResource("tileset_office")
format = 2
layer_0/name = "Floor and Walls"
layer_0/y_sort_enabled = true
layer_0/tile_data = PackedInt32Array({tile_data})

[node name="FloorZones" type="Node2D" parent="."]
z_index = -19

[node name="HallFloor" type="ColorRect" parent="FloorZones"]
offset_right = 768.0
offset_bottom = 1024.0
color = Color(0.68, 0.6, 0.46, 0.32)

[node name="MeetingFloor" type="ColorRect" parent="FloorZones"]
offset_left = 768.0
offset_right = 1536.0
offset_bottom = 400.0
color = Color(0.31, 0.43, 0.39, 0.24)

[node name="PigOfficeFloor" type="ColorRect" parent="FloorZones"]
offset_left = 768.0
offset_top = 400.0
offset_right = 1536.0
offset_bottom = 700.0
color = Color(0.43, 0.35, 0.42, 0.22)

[node name="ArchiveOfficeFloor" type="ColorRect" parent="FloorZones"]
offset_left = 768.0
offset_top = 700.0
offset_right = 1536.0
offset_bottom = 1024.0
color = Color(0.29, 0.35, 0.45, 0.26)

[node name="DoorIndicator" type="ColorRect" parent="."]
offset_left = 204.0
offset_top = 960.0
offset_right = 300.0
offset_bottom = 976.0
color = Color(0.12, 0.08, 0.04, 1)

[node name="BackDoor" type="Area2D" parent="."]
position = Vector2(252, 964)
collision_layer = 0
collision_mask = 2
script = ExtResource("2_door")
door_id = "office_back_to_street"
target_scene = "res://scenes/world/routes/office_street.tscn"
target_spawn_id = "OfficeSpawn"

[node name="CollisionShape2D" type="CollisionShape2D" parent="BackDoor"]
shape = SubResource("RectangleShape2D_door_horiz")

[node name="StreetSpawn" type="Node2D" parent="."]
position = Vector2(252, 920)

[node name="Player" type="CharacterBody2D" parent="."]
position = Vector2(252, 920)
collision_layer = 2
script = ExtResource("1_player")

[node name="CollisionShape2D" type="CollisionShape2D" parent="Player"]
position = Vector2(0, 24)
shape = SubResource("RectangleShape2D_player")

[node name="Visual" type="AnimatedSprite2D" parent="Player"]
position = Vector2(0, -8)
sprite_frames = ExtResource("4_cula_frames")
animation = &"idle_front"

[node name="Camera2D" type="Camera2D" parent="Player"]
zoom = Vector2(1.35, 1.35)
limit_left = 0
limit_top = 0
limit_right = 1536
limit_bottom = 1024
position_smoothing_enabled = true
position_smoothing_speed = 8.0

[node name="ArchiveDoorIndicator" type="ColorRect" parent="."]
offset_left = 1358.0
offset_top = 64.0
offset_right = 1442.0
offset_bottom = 80.0
color = Color(0.12, 0.08, 0.04, 1)

[node name="ArchiveDoor" type="Area2D" parent="."]
position = Vector2(1400, 76)
collision_layer = 0
collision_mask = 2
script = ExtResource("2_door")
door_id = "office_to_archive"
target_scene = "res://scenes/interiors/archive_room.tscn"
target_spawn_id = "ArchiveSpawn"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ArchiveDoor"]
shape = SubResource("RectangleShape2D_door_horiz")

[node name="ArchiveSpawn" type="Node2D" parent="."]
position = Vector2(1400, 116)

[node name="OfficeCoffeeMachine" type="Area2D" parent="."]
position = Vector2(100, 800)
collision_layer = 4
collision_mask = 2
script = ExtResource("14_minigame_trigger")
minigame_scene_path = "res://scenes/minigames/coffee_brewing.tscn"

[node name="Visual" type="ColorRect" parent="OfficeCoffeeMachine"]
offset_left = -20.0
offset_top = -24.0
offset_right = 20.0
offset_bottom = 24.0
color = Color(0, 0, 0, 0)

[node name="CollisionShape2D" type="CollisionShape2D" parent="OfficeCoffeeMachine"]
shape = SubResource("RectangleShape2D_coffee")

[node name="ReceptionDesk" type="Node2D" parent="."]
position = Vector2(1000, 600)

[node name="Visual" type="Sprite2D" parent="ReceptionDesk"]
position = Vector2(0, 35)
scale = Vector2(0.15, 0.15)
offset = Vector2(0, -502)
texture = ExtResource("16_receptionL")

[node name="Collision" type="StaticBody2D" parent="ReceptionDesk"]
collision_layer = 1
collision_mask = 0

[node name="CollisionBottom" type="CollisionShape2D" parent="ReceptionDesk/Collision"]
position = Vector2(25, 2)
shape = SubResource("RectangleShape2D_reception_desk_bottom")

[node name="CollisionLeft" type="CollisionShape2D" parent="ReceptionDesk/Collision"]
position = Vector2(-45, -43)
shape = SubResource("RectangleShape2D_reception_desk_left")

[node name="Asia" type="Area2D" parent="."]
position = Vector2(1016, 536)
collision_layer = 4
collision_mask = 2
script = ExtResource("18_asia_gd")
cabinet_node_path = NodePath("../FileCabinet")
npc_id = "asia"
display_name = "Asia"
default_facing = "front_left"

[node name="Visual" parent="Asia" instance=ExtResource("1_canon")]
position = Vector2(0, -8)
sprite_frames = ExtResource("17_asia_frames")

[node name="CollisionShape2D" type="CollisionShape2D" parent="Asia"]
shape = SubResource("RectangleShape2D_npc")

[node name="FileCabinet" type="ColorRect" parent="."]
position = Vector2(1200, 536)
size = Vector2(32, 16)
color = Color(0.3, 0.3, 0.3, 1)

[node name="MrPig" type="Area2D" parent="."]
position = Vector2(500, 300)
collision_layer = 4
collision_mask = 2
script = ExtResource("3_npc")
npc_id = "pig"
display_name = "Mr. Pig"
npc_color = Color(0.83, 0.54, 0.54, 1)

[node name="Visual" parent="MrPig" instance=ExtResource("1_canon")]
position = Vector2(0, -8)
sprite_frames = ExtResource("frames_mr_pig")

[node name="CollisionShape2D" type="CollisionShape2D" parent="MrPig"]
shape = SubResource("RectangleShape2D_npc")

[node name="Murrow" type="Area2D" parent="."]
position = Vector2(1000, 250)
collision_layer = 4
collision_mask = 2
script = ExtResource("3_npc")
npc_id = "murrow"
display_name = "Mr. Murrow"
display_name_after_meeting = "Murrow"
first_meeting_flag = "met_murrow"
npc_color = Color(0.48, 0.42, 0.29, 1)

[node name="CollisionShape2D" type="CollisionShape2D" parent="Murrow"]
shape = SubResource("RectangleShape2D_npc")

[node name="Visual" parent="Murrow" instance=ExtResource("1_canon")]
position = Vector2(0, -8)
sprite_frames = ExtResource("frames_murrow")

[node name="ProceduralBinder" type="Area2D" parent="."]
position = Vector2(1000, 160)
collision_layer = 4
collision_mask = 2
script = ExtResource("8_qhjoq")
item_id = "procedural_binder"
display_name = "Procedural Binder"
state_flag_path = "chapter1.has_law_binder"
pickup_line = "A heavy tome on administrative law. Better take it."

[node name="Visual" type="ColorRect" parent="ProceduralBinder"]
offset_left = -10.0
offset_top = -8.0
offset_right = 10.0
offset_bottom = 8.0
color = Color(0.74, 0.58, 0.22, 1)

[node name="DeskFront" type="Area2D" parent="."]
position = Vector2(1000, 600)
collision_layer = 4
collision_mask = 2
script = ExtResource("3_npc")
npc_id = "asia"
display_name = "Asia"
npc_color = Color(0, 0, 0, 0)
prompt_anchor_path = NodePath("../Asia")
default_facing = "front_left"

[node name="CollisionBottom" type="CollisionShape2D" parent="DeskFront"]
position = Vector2(25, 2)
shape = SubResource("RectangleShape2D_deskfront_bottom")

[node name="CollisionLeft" type="CollisionShape2D" parent="DeskFront"]
position = Vector2(-45, -43)
shape = SubResource("RectangleShape2D_deskfront_left")

[node name="PigIdleZone" type="Area2D" parent="."]
position = Vector2(500, 300)
collision_layer = 0
collision_mask = 2
script = ExtResource("12_pig_idle")

[node name="CollisionShape2D" type="CollisionShape2D" parent="PigIdleZone"]
shape = SubResource("RectangleShape2D_pigzone")

[node name="BehindDeskZone" type="Area2D" parent="."]
position = Vector2(1016, 536)
collision_layer = 0
collision_mask = 2
script = ExtResource("11_behind_desk")

[node name="CollisionShape2D" type="CollisionShape2D" parent="BehindDeskZone"]
shape = SubResource("RectangleShape2D_behinddsk")

[node name="Props" type="Node2D" parent="."]
y_sort_enabled = true

[node name="Window" type="Sprite2D" parent="Props"]
position = Vector2(200, 100)
z_index = -5
texture = ExtResource("p19_window")

[node name="WallCalendar" type="Sprite2D" parent="Props"]
position = Vector2(400, 100)
z_index = -5
texture = ExtResource("p02_calendar")

[node name="DeskPig" type="Sprite2D" parent="Props"]
position = Vector2(500, 317)
texture = ExtResource("p06_desk_pig")

[node name="ChairPig" type="Sprite2D" parent="Props"]
position = Vector2(500, 241)
texture = ExtResource("p03_chair")

[node name="DeskLamp" type="Sprite2D" parent="Props"]
position = Vector2(468, 289)
z_index = 2
texture = ExtResource("p17_lamp")

[node name="CoffeeMug" type="Sprite2D" parent="Props"]
position = Vector2(528, 299)
z_index = 2
texture = ExtResource("p20_mug")

[node name="TrashBin" type="Sprite2D" parent="Props"]
position = Vector2(418, 379)
texture = ExtResource("p18_trash")

[node name="Printer" type="Sprite2D" parent="Props"]
position = Vector2(100, 500)
offset = Vector2(0, -40)
texture = ExtResource("p05_printer")

[node name="CoffeeMachine" type="Sprite2D" parent="Props"]
position = Vector2(100, 800)
offset = Vector2(0, -32)
texture = ExtResource("p04_coffee")

[node name="OfficeDoor" type="Sprite2D" parent="Props"]
position = Vector2(1400, 106)
z_index = -6
texture = ExtResource("p14_door")

[node name="Certificate" type="Sprite2D" parent="Props"]
position = Vector2(1100, 106)
z_index = -5
texture = ExtResource("p15_cert")

[node name="WallClock" type="Sprite2D" parent="Props"]
position = Vector2(1500, 140)
z_index = -5
texture = ExtResource("p16_clock")

[node name="DeskSwine" type="Sprite2D" parent="Props"]
position = Vector2(1300, 250)
texture = ExtResource("p07_desk_swine")

[node name="Bookshelf" type="Sprite2D" parent="Props"]
position = Vector2(850, 106)
z_index = -3
offset = Vector2(0, -64)
texture = ExtResource("p12_bookshelf")

[node name="DeskMurrow" type="Sprite2D" parent="Props"]
position = Vector2(1000, 243)
texture = ExtResource("p08_desk_murrow")

[node name="ArchiveBoxes" type="Sprite2D" parent="Props"]
position = Vector2(1150, 275)
texture = ExtResource("p13_archive")

[node name="Fern" type="Sprite2D" parent="Props"]
position = Vector2(1080, 558)
z_index = 2
offset = Vector2(0, -40)
texture = ExtResource("p01_fern")

[node name="DeskRak" type="Sprite2D" parent="Props"]
position = Vector2(850, 850)
texture = ExtResource("p09_desk_rak")

[node name="DeskWymysl" type="Sprite2D" parent="Props"]
position = Vector2(1100, 850)
texture = ExtResource("p10_desk_wymysl")

[node name="DeskKula" type="Sprite2D" parent="Props"]
position = Vector2(1350, 850)
texture = ExtResource("p11_desk_kula")

"""

with open("godot/scenes/interiors/pig_swine_office.tscn", "w") as f:
    f.write(tscn_content)
