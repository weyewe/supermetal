=begin
3 cases: 

1. price => no price 
if there is paid invoice, can't be done   => ONLY condition where it can't be done. DONE

######### case with updating the invoice amount 

2. no price => price
Just do the changes. Update amount payable on the invoice 




# if there is invoice paid. can't do it. 

3. price => price 

# if there is paid invoice, can't be done? 
a. If total invoice to be paid is more than the initial invoice
    => if the invoice is not fully paid, just simply increase the amount
    => if it is fully paid, mark it as unpaid. 
  
b. If the total invoice to be paid is less than the initial invoice
    => if the invoice is fully paid, find the downpayment history, and increase downpayment amount
    => if the invoice is not fully paid
      => and the final invoice is fully paid => mark it as fully paid
      => and the final invoice is not fully paid => 

=end

# time for the spec. How? 

# spec for cancel. How? 