# DOCUMENTATION

 step - by step for installation

 clone repository <br>
 run -$ yarn <br>
 run -$ rake webpacker:compile <br>
 run -$ rake db:create <br>
 run -$ rake db:migrate <br>
 run -$ rails s

POSTMAN - CONSULTS

<b>CONSULT STOCK</b> = GET - http://127.0.0.1:3000/api/v1/stocks 

<b>CONSULT STOCK</b> = GET - http://127.0.0.1:3000/api/v1/stocks/show/ :NUMBER_ORDER 
PUTS YOUR NUMBER ORDER IN :NUMBER_PARAMS DIRECT ON URL

<b>ADD ORDER</b>     = POST - http://127.0.0.1:3000/api/v1/stocks 
EXEMPLE:
{
  "deliver_fee": "9.90", 
  "items": [
        {
        "amount":     "1",
        "product_id": "1"
        },
        {
        "amount":     "1",
        "product_id": "2"
        }
  ]
}
