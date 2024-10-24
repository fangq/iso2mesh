function roundnum = round_to_digits(num, prec)
% round number to the prec-th digits

roundnum = (10^prec);
roundnum = round(num * roundnum) / roundnum;
