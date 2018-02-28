export function escape_html (str) {
  str += "";  // force to string
  return str.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

export function make_address_content(address) {
  var street = escape_html(address["street"]);
  var city   = escape_html(address["city"  ]);
  var state  = escape_html(address["state" ]);
  var zip    = escape_html(address["zip"   ]);

  return `
    ${street}<br>
    ${city}, ${state} ${zip}
  `;
}
