-- =========================================================
-- custom_inventory_ui - Catálogo extendido de items/shops
-- =========================================================
-- (Opcional) Agregar columna price si no existe
ALTER TABLE `items`
  ADD COLUMN IF NOT EXISTS `price` INT(11) NOT NULL DEFAULT 0;

-- =========================================================
-- REGULAR SHOP (comida/bebida/consumo)
-- =========================================================
INSERT INTO `items` (`name`,`label`,`limit`,`rare`,`can_remove`,`price`) VALUES
('bread',           'Bread',             -1, 0, 1, 25),
('water',           'Water',             -1, 0, 1, 20),
('sandwich',        'Sandwich',          -1, 0, 1, 60),
('chocolate',       'Chocolate',         -1, 0, 1, 50),
('cola',            'Cola',              -1, 0, 1, 30),
('energy_drink',    'Energy Drink',      -1, 0, 1, 120),
('bandage',         'Bandage',           -1, 0, 1, 250),
('phone',           'Phone',               1, 0, 1, 1500)
ON DUPLICATE KEY UPDATE
  `label`=VALUES(`label`), `limit`=VALUES(`limit`), `rare`=VALUES(`rare`),
  `can_remove`=VALUES(`can_remove`), `price`=VALUES(`price`);

-- =========================================================
-- ROBS LIQUOR (bebidas alcohólicas)
-- =========================================================
INSERT INTO `items` (`name`,`label`,`limit`,`rare`,`can_remove`,`price`) VALUES
('beer',            'Beer',              -1, 0, 1, 40),
('vodka',           'Vodka',             -1, 0, 1, 120),
('whiskey',         'Whiskey',           -1, 0, 1, 180),
('wine',            'Wine',              -1, 0, 1, 90),
('tequila',         'Tequila',           -1, 0, 1, 150)
ON DUPLICATE KEY UPDATE
  `label`=VALUES(`label`), `limit`=VALUES(`limit`), `rare`=VALUES(`rare`),
  `can_remove`=VALUES(`can_remove`), `price`=VALUES(`price`);

-- =========================================================
-- YOUTOOL (herramientas)
-- =========================================================
INSERT INTO `items` (`name`,`label`,`limit`,`rare`,`can_remove`,`price`) VALUES
('lockpick',        'Lockpick',          -1, 0, 1, 800),
('repairkit',       'Repair Kit',        -1, 0, 1, 1200),
('drill',           'Drill',             -1, 0, 1, 3500),
('rope',            'Rope',              -1, 0, 1, 200),
('duct_tape',       'Duct Tape',         -1, 0, 1, 120),
('radio',           'Radio',               1, 0, 1, 900)
ON DUPLICATE KEY UPDATE
  `label`=VALUES(`label`), `limit`=VALUES(`limit`), `rare`=VALUES(`rare`),
  `can_remove`=VALUES(`can_remove`), `price`=VALUES(`price`);

-- =========================================================
-- WEAPON SHOP (armas + munición + extra)
-- Ojo: para que el label se muestre desde DB, las armas también
-- deben existir en `items`. Si ya las insertaste antes, esto actualiza.
-- =========================================================
INSERT INTO `items` (`name`,`label`,`limit`,`rare`,`can_remove`,`price`) VALUES
-- Armas cuerpo a cuerpo / utilitarias
('WEAPON_FLASHLIGHT',   'Flashlight',         1, 0, 1, 500),
('WEAPON_KNIFE',        'Knife',              1, 0, 1, 900),
('WEAPON_BAT',          'Baseball Bat',       1, 0, 1, 700),
('WEAPON_STUNGUN',      'Taser',              1, 1, 1, 80000),

-- Armas de fuego
('WEAPON_PISTOL',       'Pistol',             1, 1, 1, 45000),
('WEAPON_PUMPSHOTGUN',  'Pump Shotgun',       1, 1, 1, 90000),

-- Munición
('pistol_ammo',         'Pistol Ammo (x12)',  1, 0, 1, 300),
('smg_ammo',            'SMG Ammo (x30)',     1, 0, 1, 500),
('rifle_ammo',          'Rifle Ammo (x30)',   1, 0, 1, 700),
('shotgun_shells',      'Shotgun Shells (x8)',1, 0, 1, 450),

-- Extra (cargador)
('clip',                'Weapon Clip',        -1, 0, 1, 600)
ON DUPLICATE KEY UPDATE
  `label`=VALUES(`label`), `limit`=VALUES(`limit`), `rare`=VALUES(`rare`),
  `can_remove`=VALUES(`can_remove`), `price`=VALUES(`price`);

COMMIT;
