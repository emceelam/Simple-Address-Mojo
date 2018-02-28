import Conf from '../address_app.conf.json';
  // webpack import

export default class AjaxAddresses {
  promise_get_all () {
    return new Promise( (resolve) => {
      $.ajax({
        type: "GET",
        url: `http://${Conf.host}:${Conf.port}/api/addresses`,
        success: resolve,
        error: this.reject
      });
    })
  }
  promise_delete (id) {
    return new Promise ( (resolve) => {
      $.ajax({
        type: "DELETE",
        url: `http://${Conf.host}:${Conf.port}/api/addresses/${id}`,
        xhrFields: {
          withCredentials: true
        },
        success: resolve,
        error: this.reject
      });
    });
  }
  promise_post (addr_data) {
    return new Promise ( (resolve) => {
      $.ajax({
        type: "POST",
        url: `http://${Conf.host}:${Conf.port}/api/addresses`,
        xhrFields: {
          withCredentials: true
        },
        data : JSON.stringify(addr_data),
        headers: {
          "Content-Type" : "application/json",
        },
        dataType: "json",
        success: resolve,
        error: this.reject
      });
    });
  }
  promise_put (address) {
    var id = address["id"];
    return new Promise ( (resolve) => {
      $.ajax({
        type: "PUT",
        url: `http://${Conf.host}:${Conf.port}/api/addresses/${id}`,
        xhrFields: {
          withCredentials: true
        },
        data: JSON.stringify(address),
        headers: {
          "Content-Type" : "application/json",
        },
        dataType: "json",
        success: resolve,
        error: this.reject
      });
    });
  }

  promise_geocode (address) {
    street = encodeURI(address["street"]);
    city   = encodeURI(address["city"]);
    state  = encodeURI(address["state"]);
    zip    = encodeURI(address["zip"]);
    return new Promise ( (resolve) => {
      $.ajax({
        type: "GET",
        url: `http://${Conf.host}:${Conf.port}/api/geocode?street=${street}&city=${city}&state=${state}&zip=${zip}`,
        success: resolve,
        error: this.reject
      });
    });
  }

  // error function for failed AJAX call
  reject (jqXHR, textStatus, errorThrown) {
    console.log (
      `ajax failed: ${textStatus}, ${errorThrown}, ${jqXHR.responseText}`
    );
  }
}

