window.onload = function(){
  var value_product;
  var total_price_note;
  var sub_total_price_note;
  var min_promo_amount = 0;
  var deliver_fee; 
  var sub_value_total_html         = document.getElementById("sub-value-total");
  var stock_total_price_html       = document.getElementById("stock_total_price");
  var amount_size_html             = document.getElementById("amount-size");
  var stock_amount_html            = document.getElementById("stock_amount");
  var value_unit_product_html      = document.getElementById("value-unit-product");
  var stock_product_id_html        = document.getElementById("stock_product_id");
  var prod_details_html            = document.getElementById("prod-details");  
  var value_unit_product_note_html = document.getElementById("value-unit-product-note"); 
  var value_promo_html             = document.getElementById("value-promo"); 
  var promotion_name_html          = document.getElementById("promotion-name");  
  var promotion_min_amount_html    = document.getElementById("promotion-min-amount"); 
  var promo_note_html              = document.getElementById("promo-note");  
  var tab_prom_html                = document.getElementById("tab-prom");
  var value_total_html             = document.getElementById("value-total"); 
  var stock_deliver_fee_html       = document.getElementById("stock_deliver_fee"); 
  var deliver_fee_html             = document.getElementById("deliver-fee"); 
  document.querySelector('#stock_promotion_id').classList.add("form-select");
  prod_details_html.style.display                  = "none";   
  document.getElementById("stock_origin").value    = "APP";
  $('#stock_promotion_id').on('change', function() { 
    if(this.value != ""){
      $.ajax({
        url : "get_data",
        type : 'post', 
        beforeSend: function(xhr) {
          xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
        },
        xhrFields: {
          withCredentials: true
        },
        data: { id: this.value},
        success: function(data){
                  value_product = parseFloat(data.product.price); 
                  sub_value_total_html.innerHTML      = (parseFloat(value_product)).toFixed(2);
                  stock_total_price_html.value        = (parseFloat(value_product)).toFixed(2);
                  amount_size_html.innerHTML          = "1" ;
                  stock_amount_html.max               = parseFloat(data.product.stock, 10); 
                  value_unit_product_html.value       = (parseFloat(data.product.price)).toFixed(2);
                  stock_product_id_html.value         = data.product.id;
                  prod_details_html.style.display     = "block"; 
                  
                  // note list details
                  value_unit_product_note_html.innerHTML = (parseFloat(data.product.price)).toFixed(2);
                  if(data.promotion){
                    min_promo_amount = data.promotion.min_amount; 
                    if(amount_size_html.value > min_promo_amount){
                      total_price_note                = (parseFloat(value_product * stock_amount_html.value)).toFixed(2);
                     value_promo_html.innerHTML       = "- R$" + total_price_note - value_unit_product_note_html.value;
                    }else{
                     value_promo_html.innerHTML       = "No has"
                    };
                    promotion_name_html.value         = data.promotion.name;
                    promotion_min_amount_html.value   = "Min amount " + data.promotion.min_amount; 
                    promo_note_html.style.display     = "block";
                    tab_prom_html.style.display       = "flex";
                    value_total_html.innerHTML        = sub_total_price_note;
                  }else{ 
                    min_promo_amount = Infinity;
                    promo_note_html.style.display     = "none";
                    tab_prom_html.style.display       = "none";
                    if(isNaN(deliver_fee)){
                      sub_total_price_note            = parseFloat(value_product) ;
                      value_total_html.innerHTML      = sub_total_price_note; 
                      stock_total_price_html.value    = sub_total_price_note;
                    }else{ 
                      value_total_html.innerHTML      = sub_total_price_note;
                      sub_total_price_note            = parseFloat(parseFloat(value_product) * parseInt(stock_amount_html.value));
                      sub_total_price_note            = (parseFloat(parseFloat(sub_total_price_note) + parseFloat(deliver_fee))).toFixed(2);
                      sub_value_total_html.innerHTML  = parseFloat(sub_total_price_note) + parseFloat(deliver_fee) 
                      stock_total_price_html.value    = parseFloat(sub_total_price_note) + parseFloat(deliver_fee) ;
                    }
                  };
                }
      }); 
    }
    
  });
  $('#stock_amount').on('change', function() {    
    deliver_fee                 = (parseFloat(stock_deliver_fee_html.value)).toFixed(2);  
    amount_size_html.innerHTML  = stock_amount_html.value; 

    if(stock_amount_html.value > min_promo_amount){ 
      promo_note_html.style.display     = "block";
      if(isNaN(deliver_fee)){
        sub_total_price_note            = parseFloat(parseFloat(value_product) * parseInt(stock_amount_html.value));
        sub_total_price_note            = parseFloat(sub_total_price_note);
        sub_value_total_html.innerHTML  = (sub_total_price_note).toFixed(2);
        value_total_html.innerHTML      = (parseFloat(sub_total_price_note) - parseFloat(value_product)).toFixed(2);
       value_promo_html.innerHTML       = "- R$" + value_product
        stock_total_price_html.value    = (parseFloat(sub_total_price_note) - parseFloat(value_product)).toFixed(2);
      }else{
        sub_total_price_note            = parseFloat(parseFloat(value_product) * parseInt(stock_amount_html.value));
        sub_total_price_note            = (parseFloat(parseFloat(sub_total_price_note) + parseFloat(deliver_fee))).toFixed(2);
        sub_value_total_html.innerHTML  = (parseFloat(sub_total_price_note) + parseFloat(deliver_fee)).toFixed(2);
        value_total_html.innerHTML      = (parseFloat(sub_total_price_note) - parseFloat(value_product)).toFixed(2);
       value_promo_html.innerHTML       = "- R$" + value_product 
        stock_total_price_html.value    = (parseFloat(sub_total_price_note) - parseFloat(value_product)).toFixed(2);
      }
    }else{  
      promo_note_html.style.display     = "none";
      if(isNaN(deliver_fee)){
        sub_total_price_note            = parseFloat(parseFloat(value_product) * parseInt(stock_amount_html.value));
        sub_total_price_note            = parseFloat(sub_total_price_note);
        sub_value_total_html.innerHTML  = (sub_total_price_note).toFixed(2); 
        value_total_html.innerHTML      = (sub_total_price_note).toFixed(2); 
        stock_total_price_html.value    = (sub_total_price_note).toFixed(2);
      }else{ 
        value_total_html.innerHTML      = sub_total_price_note;
        sub_total_price_note            = parseFloat(parseFloat(value_product) * parseInt(stock_amount_html.value));
        sub_total_price_note            = (parseFloat(parseFloat(sub_total_price_note) + parseFloat(deliver_fee))).toFixed(2);
        sub_value_total_html.innerHTML  = (parseFloat(sub_total_price_note) + parseFloat(deliver_fee)).toFixed(2); 
        value_total_html.innerHTML      = (parseFloat(sub_total_price_note) + parseFloat(deliver_fee)).toFixed(2); 
        stock_total_price_html.value    = (parseFloat(sub_total_price_note) + parseFloat(deliver_fee)).toFixed(2);
      }
    };
  });
  $('#stock_deliver_fee').on('change', function() {  
    deliver_fee                     = (parseFloat(stock_deliver_fee_html.value)).toFixed(2);  
    deliver_fee_html.innerHTML      = deliver_fee;
    sub_total_price_note            = parseFloat(parseFloat(value_product) * parseInt(stock_amount_html.value));
    sub_total_price_note            = (parseFloat(parseFloat(sub_total_price_note) + parseFloat(deliver_fee))).toFixed(2);
    sub_value_total_html.innerHTML  = sub_total_price_note;
    if(stock_amount_html.value > min_promo_amount){  
      value_total_html.innerHTML    = (parseFloat(sub_total_price_note) - parseFloat(value_product)).toFixed(2); 
      stock_total_price_html.value  = (parseFloat(sub_total_price_note) - parseFloat(value_product)).toFixed(2);
    }else{ 
      value_total_html.innerHTML    = sub_total_price_note;
      stock_total_price_html.value  = sub_total_price_note;
    }
  });
};