json.extract! product, :id, :description, :stock, :cod_bars, :active, :created_at, :updated_at
json.url product_url(product, format: :json)
