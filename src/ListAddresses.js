import AjaxAddress from "./AjaxAddress";
import {make_address_content } from "./util";

export default class ListAddresses  {
  constructor (address_map) {
    this.id_to_address = {};
    this.ajax_address = new AjaxAddress();
    this.address_map = address_map;
  }
  refresh() {
    var this_obj = this;
    var ajax_address = this.ajax_address;

    ajax_address.promise_get_all().then(
      function (addresses) {
        $("#list_addresses").html("");  // reset

        if (!Array.isArray(addresses)) {
          addresses = new Array();
        }

        var id_to_address = {};
        addresses.forEach ( (address) => {
          var id = address["id"];
          this_obj.add_marker(id, address);
          this_obj.append(address);
        });
      }
    );
  }

  append (address) {
    var id = address["id"];

    // no need to append. it's already there.
    if (this.id_to_address[id]) {
      return;
    }

    this.id_to_address[id] = address;
    var address_content = make_address_content(address);       
    $("#list_addresses").append(
      `
      <li class='list-group-item' id='address_${id}'>
        <div class='btn-group' role='group'
          aria-label='edit_delete' style='float:right'>
          <button type="button" class='btn btn-outline-secondary'
            data-target="form_modal" data-whatever="Edit Address"
            id='edit_${id}'>
            Edit
          </button>
          <button type="button" class='btn btn-outline-secondary'
            id='delete_${id}' >
            Delete
          </button>
        </div>
        <div id='address_content_${id}'>
          ${address_content}
        </div>
      </li>
      `
    );

    var this_obj = this;
    var address_map = this.address_map;
    $(`#edit_${id}`).click(function() {
      this_obj.edit_address(id);
    });
    $(`#delete_${id}`).click(function() {
      this_obj.delete_address(id);
    });
    $(`#address_${id}`).hover(
      function(evt) {
        address_map.pop_marker(id);
      },
      function(evt) {
        address_map.unpop_marker(id);
      }
    );
  }

  delete_address (id) {
    var this_obj = this;
    var address_map = this.address_map;
    this.ajax_address.promise_delete(id).then(function () {
      $(`#address_${id}`).remove();
      delete this_obj.id_to_address[id];
      address_map.delete_marker(id);
    });
  }

  edit_address (id) {
    var this_obj = this;

    var address = this.id_to_address[id];
    $("#street").val(address["street"]);
    $("#city"  ).val(address["city"  ]);
    $("#state" ).val(address["state" ]);
    $("#zip"   ).val(address["zip"   ]);

    $("#address_title").text("Edit Address");
    $("#form_modal").modal("show");
    $("#save_address").off().click(function () {
      this_obj.put_address(id);
    });
  }

  post_address() {
    var this_obj = this;
    var addr_data = new Object;
    addr_data.street = $("#street").val();
    addr_data.city   = $("#city"  ).val();
    addr_data.state  = $("#state" ).val();
    addr_data.zip    = $("#zip"   ).val();

    this.ajax_address.promise_post(addr_data).then( (address) => {
      var id = address["id"];
      this_obj.append(address);
      this_obj.add_marker(id, address);
    });
  }

  put_address(id) {
    var address = {
      street: $("#street").val(),
      city  : $("#city"  ).val(),
      state : $("#state" ).val(),
      zip   : $("#zip"   ).val(),
      id    : id
    };
    this.delete_marker(id);

    var this_obj = this;
    this.ajax_address.promise_put(address).then( () => {
      var content = make_address_content(address);
      $(`#address_content_${id}`).html(content);
      this_obj.id_to_address[id] = address;
      this_obj.add_marker(id, address);
    });
  }

  add_marker (id, address) {
    var address_map = this.address_map;
    if (address["lat"] || address["lng"]) {
      setTimeout(
        function() {
          address_map.add_marker(id, address);
        },
        Math.floor(Math.random() * 1000)
      );
      return;
    }

    this.ajax_address.promise_geocode(address).then(
      function(lat_lng) {
        address["lat"] = lat_lng["lat"];
        address["lng"] = lat_lng["lng"];
        address_map.add_marker(id, address);
      },
    );
  }

  delete_marker (id) {
    this.address_map.delete_marker(id);
  }
};
