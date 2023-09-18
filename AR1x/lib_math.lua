
------------------------------------------------------------
-- Function : check_min
-- Purpose  : Clip the Variable to Min value
-- Status   : Verified
------------------------------------------------------------
function check_min(var, val)
  if var < val then
    var = val
  end
  return var
end

------------------------------------------------------------
-- Function : check_max
-- Purpose  : Clip the Variable to Max value
-- Status   : Verified
------------------------------------------------------------
function check_max(var, val)
  if var > val then
    var = val
  end
  return var
end

------------------------------------------------------------
-- Function : shift_right(num, bits)
-- Purpose  : Shifts right number by n bits
------------------------------------------------------------
function shift_right(num, bits)
  num = math.floor(num/2^bits)
  return num
end


------------------------------------------------------------
-- Function : shift_left(num, bits)
-- Purpose  : Shifts left number by n bits
------------------------------------------------------------
function shift_left(num, bits)
  num = num * 2^bits
  return num
end

------------------------------------------------------------
-- Function : to_n_bit_signed(num, bits)
-- Purpose  : Convert unsigned number to n bit signed
-- to_n_bit_signed(0x7e, 7) will return -2
-- Status   : Verified partly
------------------------------------------------------------
function to_n_bit_signed(num, bits)
  local radix
  local mask
  radix = 2^bits
  mask  = 2^(bits -1) - 1
  if num > mask then
    num = num - radix
  end
  return num
end

------------------------------------------------------------
-- Function : to_n_bit_unsigned(num, bits)
-- Purpose  : Convert unsigned number to n bit signed
-- to_n_bit_signed(0x7e, 7) will return -2
-- Status   : Verified partly
------------------------------------------------------------
function to_n_bit_unsigned(num, bits)
  return num % 2^bits
end
