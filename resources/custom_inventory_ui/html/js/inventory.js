"use strict";

const RESOURCE = (typeof GetParentResourceName === "function")
  ? GetParentResourceName()
  : "custom_inventory_ui"; // fallback si abrís la UI fuera de FiveM

let type = "normal";
let disabled = false;
let disabledFunction = null;

// Fallbacks suaves para no romper si no existen
window.invLocale = window.invLocale || {
  secondInventoryNotAvailable: "No secondary inventory available."
};

const CLOSE_KEYS = (window.Config && Array.isArray(window.Config.closeKeys))
  ? window.Config.closeKeys
  : [27]; // ESC por defecto

window.addEventListener("message", (evt) => {
  const data = evt?.data;
  if (!data || !data.action) return;

  switch (data.action) {
    case "display": {
      type = data.type;
      disabled = false;

      if (type === "normal" || type === "property") {
        $(".info-div").hide();
      } else if (type === "trunk" || type === "player" || type === "shop") {
        $(".info-div").show();
      }

      $(".ui").fadeIn();
      break;
    }

    case "hide": {
      $("#dialog").dialog("close");
      $(".ui").fadeOut();
      $(".item").remove();
      $("#otherInventory").html('<div id="noSecondInventoryMessage"></div>');
      $("#noSecondInventoryMessage").html(invLocale.secondInventoryNotAvailable);
      break;
    }

    case "setItems": {
      if (Array.isArray(data.itemList)) {
        inventorySetup(data.itemList);
        makeItemsDraggable();
      }
      break;
    }

    case "setSecondInventoryItems": {
      if (Array.isArray(data.itemList)) {
        secondInventorySetup(data.itemList);
      }
      break;
    }

    case "setShopInventoryItems": {
      if (Array.isArray(data.itemList)) {
        shopInventorySetup(data.itemList);
      }
      break;
    }

    case "setInfoText": {
      $(".info-div").html(data.text ?? "");
      break;
    }

    case "nearPlayers": {
      const givenItem = data.item; // guardamos el ítem a entregar
      $("#nearPlayers").html("");

      (data.players ?? []).forEach((p) => {
        $("#nearPlayers").append(
          `<button class="nearbyPlayerButton" data-player="${p.player}">
             ${p.label} (${p.player})
           </button>`
        );
      });

      $("#dialog").dialog("open");

      $(".nearbyPlayerButton").off("click").on("click", function () {
        $("#dialog").dialog("close");
        const playerId = $(this).data("player");
        $.post(`http://${RESOURCE}/GiveItem`, JSON.stringify({
          player: playerId,
          item: givenItem,
          number: parseInt($("#count").val(), 10)
        }));
      });
      break;
    }
  }
});

function closeInventory() {
  $.post(`http://${RESOURCE}/NUIFocusOff`, JSON.stringify({}));
}

function inventorySetup(items) {
  $("#playerInventory").html("");
  items.forEach((item, index) => {
    const count = setCount(item);
    $("#playerInventory").append(
      `<div class="slot">
         <div id="item-${index}" class="item" style="background-image:url('img/items/${item.name}.png')">
           <div class="item-count">${count}</div>
           <div class="item-name">${item.label}</div>
         </div>
         <div class="item-name-bg"></div>
       </div>`
    );
    $(`#item-${index}`).data("item", item).data("inventory", "main");
  });
}

function secondInventorySetup(items) {
  $("#otherInventory").html("");
  items.forEach((item, index) => {
    const count = setCount(item);
    $("#otherInventory").append(
      `<div class="slot">
         <div id="itemOther-${index}" class="item" style="background-image:url('img/items/${item.name}.png')">
           <div class="item-count">${count}</div>
           <div class="item-name">${item.label}</div>
         </div>
         <div class="item-name-bg"></div>
       </div>`
    );
    $(`#itemOther-${index}`).data("item", item).data("inventory", "second");
  });
}

function shopInventorySetup(items) {
  $("#otherInventory").html("");
  items.forEach((item, index) => {
    const cost = setCost(item);
    $("#otherInventory").append(
      `<div class="slot">
         <div id="itemOther-${index}" class="item" style="background-image:url('img/items/${item.name}.png')">
           <div class="item-count">${cost}</div>
           <div class="item-name">${item.label}</div>
         </div>
         <div class="item-name-bg"></div>
       </div>`
    );
    $(`#itemOther-${index}`).data("item", item).data("inventory", "second");
  });
}

function makeItemsDraggable() {
  $(".item").draggable({
    helper: "clone",
    appendTo: "body",
    zIndex: 99999,
    revert: "invalid",
    start: function () {
      if (disabled) return false;

      $(this).css("background-image", "none");
      const itemData = $(this).data("item");
      const itemInventory = $(this).data("inventory");

      if (itemInventory === "second" || !itemData?.canRemove) {
        $("#drop, #give").addClass("disabled");
      }
      if (itemInventory === "second" || !itemData?.usable) {
        $("#use").addClass("disabled");
      }
    },
    stop: function () {
      const itemData = $(this).data("item");
      if (itemData?.name) {
        $(this).css("background-image", `url('img/items/${itemData.name}.png')`);
        $("#drop, #use, #give").removeClass("disabled");
      }
    }
  });
}

function Interval(time) {
  let timer = false;
  this.start = function () {
    if (this.isRunning()) {
      clearInterval(timer);
      timer = false;
    }
    timer = setInterval(() => { disabled = false; }, time);
  };
  this.stop = function () { clearInterval(timer); timer = false; };
  this.isRunning = function () { return timer !== false; };
}

function disableInventory(ms) {
  disabled = true;
  if (disabledFunction === null) {
    disabledFunction = new Interval(ms);
  } else if (disabledFunction.isRunning()) {
    disabledFunction.stop();
  }
  disabledFunction.start();
}

function setCount(item) {
  let count = item.count;

  if (item.limit > 0) {
    count = `${item.count} / ${item.limit}`;
  }
  if (item.type === "item_weapon") {
    count = item.count > 0 ? `<img src="img/bullet.png" class="ammoIcon"> ${item.count}` : "";
  }
  if (item.type === "item_account" || item.type === "item_money") {
    count = formatMoney(item.count);
  }
  return count;
}

function setCost(item) {
  const price = Number(item.price) || 0;
  return price <= 0 ? "$0" : `$${price}`;
}

function formatMoney(n, c, d, t) {
  const c2 = isNaN(c = Math.abs(c)) ? 2 : c;
  const dec = d === undefined ? "." : d;
  const sep = t === undefined ? "," : t;
  const s = n < 0 ? "-" : "";
  const i = String(parseInt(Math.abs(Number(n) || 0).toFixed(c2)));
  const j = (i.length > 3) ? i.length % 3 : 0;
  return s + (j ? i.substr(0, j) + sep : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, `$1${sep}`);
}

$(document).ready(function () {
  $("#count").on("focus", function () {
    $(this).val("");
  }).on("blur", function () {
    if ($(this).val() === "") $(this).val("1");
  });

  $("body").on("keyup", function (key) {
    if (CLOSE_KEYS.includes(key.which)) closeInventory();
  });

  $("#use").droppable({
    hoverClass: "hoverControl",
    drop: function (event, ui) {
      const itemData = ui.draggable.data("item");
      if (!itemData?.usable) return;
      const itemInventory = ui.draggable.data("inventory");
      if (itemInventory !== "main") return;

      disableInventory(300);
      $.post(`http://${RESOURCE}/UseItem`, JSON.stringify({ item: itemData }));
    }
  });

  $("#give").droppable({
    hoverClass: "hoverControl",
    drop: function (event, ui) {
      const itemData = ui.draggable.data("item");
      if (!itemData?.canRemove) return;
      const itemInventory = ui.draggable.data("inventory");
      if (itemInventory !== "main") return;

      disableInventory(300);
      $.post(`http://${RESOURCE}/GetNearPlayers`, JSON.stringify({ item: itemData }));
    }
  });

  $("#drop").droppable({
    hoverClass: "hoverControl",
    drop: function (event, ui) {
      const itemData = ui.draggable.data("item");
      if (!itemData?.canRemove) return;
      const itemInventory = ui.draggable.data("inventory");
      if (itemInventory !== "main") return;

      disableInventory(300);
      $.post(`http://${RESOURCE}/DropItem`, JSON.stringify({
        item: itemData,
        number: parseInt($("#count").val(), 10)
      }));
    }
  });

  $("#playerInventory").droppable({
    drop: function (event, ui) {
      const itemData = ui.draggable.data("item");
      const itemInventory = ui.draggable.data("inventory");
      if (itemInventory !== "second") return;

      disableInventory(500);
      if (type === "trunk") {
        $.post(`http://${RESOURCE}/TakeFromTrunk`, JSON.stringify({
          item: itemData, number: parseInt($("#count").val(), 10)
        }));
      } else if (type === "property") {
        $.post(`http://${RESOURCE}/TakeFromProperty`, JSON.stringify({
          item: itemData, number: parseInt($("#count").val(), 10)
        }));
      } else if (type === "player") {
        $.post(`http://${RESOURCE}/TakeFromPlayer`, JSON.stringify({
          item: itemData, number: parseInt($("#count").val(), 10)
        }));
      } else if (type === "shop") {
        $.post(`http://${RESOURCE}/TakeFromShop`, JSON.stringify({
          item: itemData, number: parseInt($("#count").val(), 10)
        }));
      }
    }
  });

  $("#otherInventory").droppable({
    drop: function (event, ui) {
      const itemData = ui.draggable.data("item");
      const itemInventory = ui.draggable.data("inventory");
      if (itemInventory !== "main") return;

      disableInventory(500);
      if (type === "trunk") {
        $.post(`http://${RESOURCE}/PutIntoTrunk`, JSON.stringify({
          item: itemData, number: parseInt($("#count").val(), 10)
        }));
      } else if (type === "property") {
        $.post(`http://${RESOURCE}/PutIntoProperty`, JSON.stringify({
          item: itemData, number: parseInt($("#count").val(), 10)
        }));
      } else if (type === "player") {
        $.post(`http://${RESOURCE}/PutIntoPlayer`, JSON.stringify({
          item: itemData, number: parseInt($("#count").val(), 10)
        }));
      }
    }
  });

  $("#count").on("keypress keyup blur", function (event) {
    $(this).val($(this).val().replace(/[^\d].+/, ""));
    if (event.which < 48 || event.which > 57) event.preventDefault();
  });
});

// Extensión para cerrar el diálogo haciendo click fuera (si se habilita)
$.widget("ui.dialog", $.ui.dialog, {
  options: { clickOutside: false, clickOutsideTrigger: "" },
  open: function () {
    const clickOutsideTriggerEl = $(this.options.clickOutsideTrigger);
    const that = this;
    if (this.options.clickOutside) {
      $(document).on("click.ui.dialogClickOutside" + that.eventNamespace, function (event) {
        const $target = $(event.target);
        if ($target.closest($(clickOutsideTriggerEl)).length === 0 &&
            $target.closest($(that.uiDialog)).length === 0) {
          that.close();
        }
      });
    }
    this._super();
  },
  close: function () {
    $(document).off("click.ui.dialogClickOutside" + this.eventNamespace);
    this._super();
  }
});
