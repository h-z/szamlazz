# Szamlazz

A Ruby wrapper for the [Szamlazz.hu API](https://docs.szamlazz.hu/).

## Installation

Install the gem and add to the application's Gemfile by executing:

```shell
bundle add szamlazz --git https://github.com/h-z/szamlazz
```

## Usage

```ruby
require 'szamlazz'
```

### Create a buyer
```ruby
buyer = Szamlazz::Buyer.new(
  name: "Vevő neve",
  tax_number: "12345678-1-42",
  address: Szamlazz::Address.new(
    name: "Cím név",
    country: "Magyarország",
    zip: "9999",
    city: "Budapest",
    address: "Kossuth utca 1."
  ),
  post_address: Szamlazz::Address.new(
    name: "Számlázási cím név",
    country: "Magyarország",
    zip: "9999",
    city: "Budapest",
    address: "Kossuth utca 12."
  )
)
```
### Create a seller
```ruby
seller = Szamlazz::Seller.new(
  bank_name: 'TheBank Bank',
  bank_account: '11111111-11111111-11111111',
)
```
### Create invoice items

You can create an item by passing the label, the VAT rate, the quantity and the gross or net unit price.

```ruby
item = Szamlazz::Item.new({ label: "Valami cucc", gross_unit_price: 100, quantity: 3, vat: 87 })
other_item = Szamlazz::Item.new({ label: "Cucc", net_unit_price: 82, quantity: 10, vat: 15 })

item.gross_value # => 300
item.net_value # => 160.43

other_item.net_value # => 820
other_item.gross_value # => 943
```
### Create an invoice
```ruby
invoice = Szamlazz::Invoice.new(
  issue_date: Date.today,
  due_date: Date.today + 7,
  fulfillment_date: Date.today,
  payment_method: "Átutalás",
  language: "hu",
  currency: "HUF",
  exchange_bank: "OTP",
  external_key: 3333,
  prefix: "MYCOMPANY",
  seller: seller,
  buyer: buyer,
  items: [ item ]
)
```

### Create a client
```ruby
client = Szamlazz::Client.new(
  user: 'merchant-1@szamlazz.merchant',
  password: 's3cr3t',
  token: 'TKN-1234567890',
  download_invoice: true
)
```

### Issue an invoice
```ruby
response = client.issue_invoice(invoice)
# => response.success? = true
# => response.invoice_number = "MYCOMPANY-00000001"
```

### Cancel an invoice
```ruby
response = client.reverse_invoice("MYCOMPANY-00000001")
# => response.success? = true
```

### Add credit to an invoice
```ruby
payments = [
  Szamlazz::Payment.new(
    amount: 10_000,
    date: Date.today,
    title: "Átutalás",
    description: "Köszönjük a befizetést!"
  )
]
response = client.credit_invoice("MYCOMPANY-00000001", payments, false)
# => response.success? = true
```

### Download an invoice
```ruby
response = client.download_invoice_pdf(invoice)
# => response.success? = true
# => response.invoice_pdf = <PDF data>
```

### Download an invoice in XML format
```ruby
response = client.download_invoice_xml(invoice)
# => response.success? = true
# => response.invoice_xml = <Nokogiri::XML>
```

### Remove a proform invoice
```ruby
response = client.remove_proform_invoice("MYCOMPANY-00000001")
# => response.success? = true
```
