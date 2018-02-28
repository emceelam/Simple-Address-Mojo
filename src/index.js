import AddressMap from "./AddressMap";
import ListAddresses from "./ListAddresses";

export function initMap() {
  var address_map = new AddressMap;
  address_map.init();

  var list_addresses = new ListAddresses(address_map);
  list_addresses.refresh();

  $("#new_address").click(function() {
    $("#address_title").text("New Address");

    // reset form values
    $("#street").val('');
    $("#city"  ).val('');
    $("#state" ).val('CA');
    $("#zip"   ).val('');

    $("#save_address").off().click(function () {
      list_addresses.post_address();
      //$("form_modal").close();
    });
  });
}


// google map requires that initMap be globally available
window.initMap = initMap;

