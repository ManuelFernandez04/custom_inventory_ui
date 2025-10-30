"use strict";

/**
 * Configuración base para la interfaz de inventario.
 * Compatible con inventory.js (auto-cierre, teclas, texto, etc.)
 */

window.Config = {
  // Teclas para cerrar el inventario
  // 27 = ESC, 8 = Backspace, 113 = F2 (opcional)
  closeKeys: [27, 8, 113]
};

// Textos de idioma
window.invLocale = {
  secondInventoryNotAvailable: "No secondary inventory available.",
  cash: "Cash",
  black_money: "Dirty Money",
  player_nearby: "Player no longer nearby.",
  players_nearby: "No nearby players.",
  openinv_help: "Open another player's inventory.",
  openinv_id: "Player ID",
  no_permissions: "You don’t have permissions to do that.",
  no_player: "No player found with that ID.",
  player_inventory: "Player Inventory"
};
