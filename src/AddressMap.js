export default class AddressMap{
  constructor() {
    this.id_to_marker = {};
    this.id_to_popup = {};
    this.map = null;
  }
  init() {
    this.map = new google.maps.Map(
      document.getElementById("gmap"),
      {
        zoom: 10,
        center: {lat: 37.4230750, lng: -121.8818120},
      }
    );
  }
  add_marker(id, address) {
    var street = address["street"];
    var lat    = address["lat"   ];
    var lng    = address["lng"   ];

    var marker = new google.maps.Marker({
      title     : street,
      position  : {'lat': lat, 'lng': lng},
      animation : google.maps.Animation.DROP,
      map       : this.map,
    });
    this.id_to_marker[id] = marker;
  }
  delete_marker(id) {
    var marker = this.id_to_marker[id];
    marker.setMap(null);
    delete this.id_to_marker[id];
  }
  pop_marker(id) {
    var marker = this.id_to_marker[id];
    if (!marker) {   // marker not yet initialized
      return;
    }

    marker.setLabel("A"+id);
  }
  unpop_marker(id) {
    var marker = this.id_to_marker[id];
    if (!marker) {   // marker not yet initialized
      return;
    }

    marker.setLabel(null);
  }
}

