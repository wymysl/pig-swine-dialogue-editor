#!/usr/bin/env python3
"""Generate the complete pig_swine_office.tscn from scratch — two-row layout.

Layout (24×16 floor, 64px tiles):

  Top half (rows 0-5):
    cols 0-7   Meeting room        (8×6, 512×384 px)
    cols 8-13  Pig's Office        (6×6, 384×384 px)
    cols 14-18 Desks / bullpen     (5×6 floor; col 19 is wall column)
    cols 20-23 Files               (4×6, 256×384 px)

  Row 6: interior horizontal divider. Doorways at cols 3-4 (Meeting↔Hall),
         10-11 (Pig's Office↔Hall), 21-22 (Files↔Cabinets).

  Bottom half (rows 7-15):
    cols 0-13  Hall                (14×9 — main hallway)
    cols 14-18 Reception           (5×9 — open to Hall, desk forms L-boundary)
    cols 20-23 Cabinets+Coffee     (4×9 with Coffee corner at cols 22-23, row 15)

  Col 19 is a continuous wall column rows 0-5 and 7-15. Doorway gaps:
    rows 1-2  (Desks↔Files)
    rows 9-10 (Reception↔Cabinets)

  Exterior wall ring:
    row -1 (north)  cols -1..24, gap at cols 21-22 (archive door)
    row 16 (south)  cols -1..24, gap at cols 3-4   (street door)
    col -1 (west)   rows 0..15
    col 24 (east)   rows 0..15

Collision is baked into wall tiles (office_tileset.tres, source 1). No separate
StaticBody2D wall nodes. Camera limit_left=0 / right=1536 hides the off-screen
west/east/south wall tiles; only the top wall row (y=-64..0) is visible.

TileMapLayer binary format (verified by _probe_tilemap_format.py):
  2-byte zero prefix + (12 bytes × N cells)
  Each cell = 6 little-endian int16:
    (x, y, source_id, atlas_x, atlas_y, alt_tile)
  Whole blob base64-encoded inside PackedByteArray("...").
"""

import base64
import hashlib
import struct
from pathlib import Path

# --- Constants -------------------------------------------------------------

SEED = 42
W, H = 24, 16   # floor dimensions in tile cells
TILE = 64       # pixels per tile

FLOOR_VARIANTS = [(0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1)]
WALL_VARIANTS = [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0)]

# Doorway specs
HORIZ_DIVIDER_GAPS = {3, 4, 10, 11, 21, 22}   # row 6 doorway columns
TOP_WALL_GAPS = {21, 22}                       # archive door columns
BOTTOM_WALL_GAPS = {3, 4}                      # street door columns
DESKS_FILES_DOOR_ROWS = {1, 2}                 # col 19, rows 0-5
RECEPTION_CABINETS_DOOR_ROWS = {9, 10}         # col 19, rows 7-15

# --- TileMapLayer binary encoding ------------------------------------------

def det_pick(variants, x, y, salt=""):
    h = hashlib.md5(f"{SEED}:{salt}:{x}:{y}".encode()).hexdigest()
    return variants[int(h, 16) % len(variants)]

def encode_cell(x, y, src, ax, ay, alt=0):
    return struct.pack("<6h", x, y, src, ax, ay, alt)

def build_layer_blob(cells):
    """cells: iterable of (x, y, src, ax, ay, alt). Returns base64 string."""
    parts = [b"\x00\x00"]  # 2-byte format prefix
    for c in cells:
        parts.append(encode_cell(*c))
    return base64.b64encode(b"".join(parts)).decode("ascii")

def floor_cells():
    cells = []
    for y in range(H):
        for x in range(W):
            ax, ay = det_pick(FLOOR_VARIANTS, x, y, "floor")
            cells.append((x, y, 0, ax, ay, 0))
    return cells

def wall_positions():
    walls = set()
    # Top exterior (row -1) — gap at archive door
    for x in range(-1, W + 1):
        if x not in TOP_WALL_GAPS:
            walls.add((x, -1))
    # Bottom exterior (row 16) — gap at street door
    for x in range(-1, W + 1):
        if x not in BOTTOM_WALL_GAPS:
            walls.add((x, H))
    # West / East exterior
    for y in range(0, H):
        walls.add((-1, y))
        walls.add((W, y))
    # Interior horizontal divider at row 6
    for x in range(0, W):
        if x not in HORIZ_DIVIDER_GAPS:
            walls.add((x, 6))
    # Vertical wall at col 19, top half (rows 0-5)
    for y in range(0, 6):
        if y not in DESKS_FILES_DOOR_ROWS:
            walls.add((19, y))
    # Vertical wall at col 19, bottom half (rows 7-15)
    for y in range(7, H):
        if y not in RECEPTION_CABINETS_DOOR_ROWS:
            walls.add((19, y))
    return walls

def wall_cells():
    cells = []
    for (x, y) in sorted(wall_positions()):
        ax, ay = det_pick(WALL_VARIANTS, x, y, "wall")
        cells.append((x, y, 1, ax, ay, 0))
    return cells

# --- Scene template --------------------------------------------------------

SCENE_TEMPLATE = '''[gd_scene format=4 uid="uid://p2dlx18voq7o"]

[ext_resource type="PackedScene" path="res://scenes/components/npc_walking_canon.tscn" id="1_canon"]
[ext_resource type="Script" path="res://scripts/actors/player.gd" id="1_player"]
[ext_resource type="Script" path="res://scripts/actors/door.gd" id="2_door"]
[ext_resource type="Script" path="res://scripts/actors/npc.gd" id="3_npc"]
[ext_resource type="SpriteFrames" path="res://art/sprites/cula/cula_sprite_frames.tres" id="4_cula_frames"]
[ext_resource type="Script" path="res://scripts/actors/pickup.gd" id="8_qhjoq"]
[ext_resource type="Script" path="res://scripts/actors/behind_desk_zone.gd" id="11_behind_desk"]
[ext_resource type="Script" path="res://scripts/actors/pig_idle_zone.gd" id="12_pig_idle"]
[ext_resource type="AudioStream" path="res://audio/music/office.mp3" id="13_music"]
[ext_resource type="Script" path="res://scripts/actors/minigame_trigger.gd" id="14_minigame_trigger"]
[ext_resource type="SpriteFrames" path="res://art/sprites/asia/asia_sprite_frames.tres" id="17_asia_frames"]
[ext_resource type="Script" path="res://scripts/actors/asia.gd" id="18_asia_gd"]
[ext_resource type="SpriteFrames" path="res://art/sprites/mr_pig/mr_pig_sprite_frames.tres" id="frames_mr_pig"]
[ext_resource type="SpriteFrames" path="res://art/sprites/murrow/murrow_sprite_frames.tres" id="frames_murrow"]
[ext_resource type="SpriteFrames" path="res://art/sprites/halina/halina_sprite_frames.tres" id="frames_halina"]
[ext_resource type="Script" path="res://scripts/actors/meeting_room_trigger.gd" id="meeting_room_trigger_gd"]
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
[ext_resource type="Texture2D" path="res://art/props/office/desk_asia_new.png" id="p21_desk_asia"]
[ext_resource type="TileSet" uid="uid://d4nf6vj8sxrcd" path="res://art/tilesets/office_tileset.tres" id="tileset_office"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_door_horiz"]
size = Vector2(48, 16)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_reception_desk_bottom"]
size = Vector2(80, 30)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_reception_desk_left"]
size = Vector2(25, 60)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_npc"]
size = Vector2(52, 56)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_deskfront_bottom"]
size = Vector2(80, 30)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_deskfront_left"]
size = Vector2(25, 60)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_coffee"]
size = Vector2(48, 48)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_pigzone"]
size = Vector2(144, 128)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_behinddsk"]
size = Vector2(108, 120)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_player"]
size = Vector2(24, 24)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_meeting_boundary"]
size = Vector2(512, 16)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_meeting_trigger"]
size = Vector2(512, 40)

[node name="PigSwineOffice" type="Node2D"]
y_sort_enabled = true

[node name="Music" type="AudioStreamPlayer" parent="."]
process_mode = 3
stream = ExtResource("13_music")
autoplay = true

[node name="Floor" type="TileMapLayer" parent="."]
use_parent_material = true
tile_map_data = PackedByteArray("{floor_b64}")
tile_set = ExtResource("tileset_office")

[node name="Walls" type="TileMapLayer" parent="."]
y_sort_enabled = true
use_parent_material = true
tile_map_data = PackedByteArray("{walls_b64}")
tile_set = ExtResource("tileset_office")

[node name="FloorZones" type="Node2D" parent="."]
z_index = -19

[node name="MeetingFloor" type="ColorRect" parent="FloorZones"]
offset_left = 0.0
offset_top = 0.0
offset_right = 512.0
offset_bottom = 384.0
color = Color(0.31, 0.43, 0.39, 0.24)

[node name="PigOfficeFloor" type="ColorRect" parent="FloorZones"]
offset_left = 512.0
offset_top = 0.0
offset_right = 896.0
offset_bottom = 384.0
color = Color(0.43, 0.35, 0.42, 0.22)

[node name="DesksFloor" type="ColorRect" parent="FloorZones"]
offset_left = 896.0
offset_top = 0.0
offset_right = 1216.0
offset_bottom = 384.0
color = Color(0.34, 0.42, 0.46, 0.22)

[node name="FilesFloor" type="ColorRect" parent="FloorZones"]
offset_left = 1280.0
offset_top = 0.0
offset_right = 1536.0
offset_bottom = 384.0
color = Color(0.29, 0.35, 0.45, 0.26)

[node name="HallFloor" type="ColorRect" parent="FloorZones"]
offset_left = 0.0
offset_top = 448.0
offset_right = 896.0
offset_bottom = 1024.0
color = Color(0.68, 0.6, 0.46, 0.32)

[node name="ReceptionFloor" type="ColorRect" parent="FloorZones"]
offset_left = 896.0
offset_top = 448.0
offset_right = 1216.0
offset_bottom = 1024.0
color = Color(0.55, 0.5, 0.42, 0.26)

[node name="CabinetsFloor" type="ColorRect" parent="FloorZones"]
offset_left = 1280.0
offset_top = 448.0
offset_right = 1536.0
offset_bottom = 960.0
color = Color(0.38, 0.42, 0.5, 0.22)

[node name="CoffeeFloor" type="ColorRect" parent="FloorZones"]
offset_left = 1408.0
offset_top = 960.0
offset_right = 1536.0
offset_bottom = 1024.0
color = Color(0.5, 0.42, 0.32, 0.28)

[node name="Props" type="Node2D" parent="."]
y_sort_enabled = true

[node name="Window" type="Sprite2D" parent="Props"]
z_index = -5
position = Vector2(192, 40)
texture = ExtResource("p19_window")

[node name="WallCalendar" type="Sprite2D" parent="Props"]
z_index = -5
position = Vector2(384, 40)
texture = ExtResource("p02_calendar")

[node name="Certificate" type="Sprite2D" parent="Props"]
z_index = -5
position = Vector2(704, 40)
texture = ExtResource("p15_cert")

[node name="WallClock" type="Sprite2D" parent="Props"]
z_index = -5
position = Vector2(1408, 40)
texture = ExtResource("p16_clock")

[node name="OfficeDoor" type="Sprite2D" parent="Props"]
z_index = -6
position = Vector2(256, 1024)
texture = ExtResource("p14_door")
offset = Vector2(0, -64)

[node name="Bookshelf" type="Sprite2D" parent="Props"]
z_index = -3
position = Vector2(560, 70)
texture = ExtResource("p12_bookshelf")
offset = Vector2(0, -64)

[node name="ChairPig" type="Sprite2D" parent="Props"]
position = Vector2(704, 180)
texture = ExtResource("p03_chair")
offset = Vector2(0, -46)

[node name="DeskPig" type="Sprite2D" parent="Props"]
position = Vector2(704, 274)
texture = ExtResource("p06_desk_pig")
offset = Vector2(0, -64)

[node name="DeskLamp" type="Sprite2D" parent="Props"]
z_index = 2
position = Vector2(672, 182)
texture = ExtResource("p17_lamp")

[node name="CoffeeMug" type="Sprite2D" parent="Props"]
z_index = 2
position = Vector2(732, 192)
texture = ExtResource("p20_mug")

[node name="TrashBin" type="Sprite2D" parent="Props"]
position = Vector2(560, 340)
texture = ExtResource("p18_trash")
offset = Vector2(0, -28)

[node name="DeskMurrow" type="Sprite2D" parent="Props"]
position = Vector2(960, 260)
texture = ExtResource("p08_desk_murrow")
offset = Vector2(0, -64)

[node name="DeskSwine" type="Sprite2D" parent="Props"]
position = Vector2(1120, 260)
texture = ExtResource("p07_desk_swine")
offset = Vector2(0, -64)

[node name="DeskRak" type="Sprite2D" parent="Props"]
position = Vector2(960, 360)
texture = ExtResource("p09_desk_rak")
offset = Vector2(0, -48)

[node name="DeskWymysl" type="Sprite2D" parent="Props"]
position = Vector2(1056, 360)
texture = ExtResource("p10_desk_wymysl")
offset = Vector2(0, -64)

[node name="DeskKula" type="Sprite2D" parent="Props"]
position = Vector2(1152, 360)
texture = ExtResource("p11_desk_kula")
offset = Vector2(0, -56)

[node name="ArchiveBoxes" type="Sprite2D" parent="Props"]
position = Vector2(1408, 240)
texture = ExtResource("p13_archive")
offset = Vector2(0, -48)

[node name="Couch_TODO_placeholder" type="ColorRect" parent="Props"]
offset_left = 64.0
offset_top = 416.0
offset_right = 256.0
offset_bottom = 480.0
color = Color(0.42, 0.28, 0.22, 0.8)

[node name="Printer" type="Sprite2D" parent="Props"]
position = Vector2(864, 484)
texture = ExtResource("p05_printer")
offset = Vector2(0, -40)

[node name="CoffeeMachine" type="Sprite2D" parent="Props"]
position = Vector2(1472, 996)
texture = ExtResource("p04_coffee")
offset = Vector2(0, -32)

[node name="ReceptionDesk" type="Sprite2D" parent="Props"]
position = Vector2(1056, 740)
texture = ExtResource("p21_desk_asia")
offset = Vector2(0, -64)

[node name="Fern" type="Sprite2D" parent="Props"]
z_index = 2
position = Vector2(1180, 640)
texture = ExtResource("p01_fern")
offset = Vector2(0, -40)

[node name="DoorIndicator" type="ColorRect" parent="."]
offset_left = 192.0
offset_top = 1024.0
offset_right = 320.0
offset_bottom = 1040.0
color = Color(0.12, 0.08, 0.04, 1)

[node name="BackDoor" type="Area2D" parent="."]
position = Vector2(256, 1028)
collision_layer = 0
collision_mask = 2
script = ExtResource("2_door")
door_id = "office_back_to_street"
target_scene = "res://scenes/world/routes/office_street.tscn"
target_spawn_id = "OfficeSpawn"

[node name="CollisionShape2D" type="CollisionShape2D" parent="BackDoor"]
shape = SubResource("RectangleShape2D_door_horiz")

[node name="StreetSpawn" type="Node2D" parent="."]
position = Vector2(256, 980)

[node name="ArchiveDoorIndicator" type="ColorRect" parent="."]
offset_left = 1344.0
offset_top = -16.0
offset_right = 1472.0
offset_bottom = 0.0
color = Color(0.12, 0.08, 0.04, 1)

[node name="ArchiveDoor" type="Area2D" parent="."]
position = Vector2(1408, -4)
collision_layer = 0
collision_mask = 2
script = ExtResource("2_door")
door_id = "office_to_archive"
target_scene = "res://scenes/interiors/archive_room.tscn"
target_spawn_id = "ArchiveSpawn"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ArchiveDoor"]
shape = SubResource("RectangleShape2D_door_horiz")

[node name="ArchiveSpawn" type="Node2D" parent="."]
position = Vector2(1408, 48)

[node name="ReceptionDeskCollision" type="StaticBody2D" parent="."]
position = Vector2(1056, 740)
collision_mask = 0

[node name="CollisionBottom" type="CollisionShape2D" parent="ReceptionDeskCollision"]
position = Vector2(5, -10)
shape = SubResource("RectangleShape2D_reception_desk_bottom")

[node name="CollisionLeft" type="CollisionShape2D" parent="ReceptionDeskCollision"]
position = Vector2(-40, -35)
shape = SubResource("RectangleShape2D_reception_desk_left")

[node name="Asia" type="Area2D" parent="."]
position = Vector2(1056, 680)
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
offset_left = 1180.0
offset_top = 768.0
offset_right = 1212.0
offset_bottom = 784.0
color = Color(0.3, 0.3, 0.3, 1)

[node name="DeskFront" type="Area2D" parent="."]
position = Vector2(1056, 740)
collision_layer = 4
collision_mask = 2
script = ExtResource("3_npc")
npc_id = "asia"
display_name = "Asia"
prompt_anchor_path = NodePath("../Asia")
npc_color = Color(0, 0, 0, 0)
default_facing = "front_left"

[node name="CollisionBottom" type="CollisionShape2D" parent="DeskFront"]
position = Vector2(5, -10)
shape = SubResource("RectangleShape2D_deskfront_bottom")

[node name="CollisionLeft" type="CollisionShape2D" parent="DeskFront"]
position = Vector2(-40, -35)
shape = SubResource("RectangleShape2D_deskfront_left")

[node name="MrPig" type="Area2D" parent="."]
position = Vector2(704, 220)
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
position = Vector2(960, 200)
collision_layer = 4
collision_mask = 2
script = ExtResource("3_npc")
npc_id = "murrow"
display_name = "Mr. Murrow"
display_name_after_meeting = "Murrow"
first_meeting_flag = "met_murrow"
npc_color = Color(0.48, 0.42, 0.29, 1)

[node name="Visual" parent="Murrow" instance=ExtResource("1_canon")]
position = Vector2(0, -8)
sprite_frames = ExtResource("frames_murrow")

[node name="CollisionShape2D" type="CollisionShape2D" parent="Murrow"]
shape = SubResource("RectangleShape2D_npc")

[node name="Halina" type="Area2D" parent="."]
position = Vector2(256, 192)
collision_layer = 4
collision_mask = 2
script = ExtResource("3_npc")
npc_id = "halina"
display_name = "Mrs. Sikorska"
default_facing = "front"
presence_flags = Array[String](["halina_arrived"])
presence_logic = "all"

[node name="Visual" parent="Halina" instance=ExtResource("1_canon")]
position = Vector2(0, -8)
sprite_frames = ExtResource("frames_halina")

[node name="CollisionShape2D" type="CollisionShape2D" parent="Halina"]
shape = SubResource("RectangleShape2D_npc")

[node name="MeetingRoomBoundary" type="StaticBody2D" parent="."]
position = Vector2(256, 392)
collision_mask = 0

[node name="CollisionShape2D" type="CollisionShape2D" parent="MeetingRoomBoundary"]
shape = SubResource("RectangleShape2D_meeting_boundary")

[node name="MeetingRoomEntryTrigger" type="Area2D" parent="."]
position = Vector2(256, 416)
collision_layer = 0
collision_mask = 2
script = ExtResource("meeting_room_trigger_gd")
boundary_path = NodePath("../MeetingRoomBoundary")

[node name="CollisionShape2D" type="CollisionShape2D" parent="MeetingRoomEntryTrigger"]
shape = SubResource("RectangleShape2D_meeting_trigger")

[node name="ProceduralBinder" type="Area2D" parent="."]
position = Vector2(1344, 160)
collision_layer = 4
collision_mask = 2
script = ExtResource("8_qhjoq")
item_id = "procedural_binder"
display_name = "Procedural Binder"
state_flag_path = "chapter1.has_law_binder"

[node name="Visual" type="ColorRect" parent="ProceduralBinder"]
offset_left = -10.0
offset_top = -8.0
offset_right = 10.0
offset_bottom = 8.0
color = Color(0.74, 0.58, 0.22, 1)

[node name="OfficeCoffeeMachine" type="Area2D" parent="."]
position = Vector2(1472, 996)
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

[node name="PigIdleZone" type="Area2D" parent="."]
position = Vector2(704, 240)
collision_layer = 0
collision_mask = 2
script = ExtResource("12_pig_idle")

[node name="CollisionShape2D" type="CollisionShape2D" parent="PigIdleZone"]
shape = SubResource("RectangleShape2D_pigzone")

[node name="BehindDeskZone" type="Area2D" parent="."]
position = Vector2(1056, 680)
collision_layer = 0
collision_mask = 2
script = ExtResource("11_behind_desk")

[node name="CollisionShape2D" type="CollisionShape2D" parent="BehindDeskZone"]
shape = SubResource("RectangleShape2D_behinddsk")

[node name="Player" type="CharacterBody2D" parent="."]
position = Vector2(256, 980)
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
limit_top = -64
limit_right = 1536
limit_bottom = 1024
position_smoothing_enabled = true
position_smoothing_speed = 8.0
'''

def main():
    floor_b64 = build_layer_blob(floor_cells())
    walls_b64 = build_layer_blob(wall_cells())

    scene = SCENE_TEMPLATE.format(floor_b64=floor_b64, walls_b64=walls_b64)
    out_path = Path(__file__).parent / "pig_swine_office.tscn"
    out_path.write_text(scene, newline="\n")

    n_floor = len(floor_cells())
    walls_set = wall_positions()

    print(f"Written: {out_path}")
    print(f"Floor cells: {n_floor} (expected {W*H} = 384)")
    print(f"Wall cells: {len(walls_set)}")
    print(f"Floor blob size: {len(base64.b64decode(floor_b64))} bytes "
          f"(= 2 + 12 × {n_floor})")
    print(f"Walls blob size: {len(base64.b64decode(walls_b64))} bytes "
          f"(= 2 + 12 × {len(walls_set)})")

    assert n_floor == W * H, f"Floor mismatch: {n_floor} != {W*H}"
    assert len(base64.b64decode(floor_b64)) == 2 + 12 * n_floor

if __name__ == "__main__":
    main()
