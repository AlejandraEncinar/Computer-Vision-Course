function bflt=bilateralfilter(img,w,sigma)

sigma_d=sigma(1);
sigma_r=sigma(2);
[r,c]=size(img);

      
for i=w+1:r-w
  for j=w+1:c-w
      bm=0;
 mm=0;
wf1=0;
 wf2=0;
     for k=i-w:i+w
         for l=j-w:j+w
wf1=img(k,l)*exp(-(img(i,j)-img(k,l))^2/(2*sigma_r^2)-((i-k)^2+(j-l)^2)/(2*sigma_d^2));

wf2=exp(-(img(i,j)-img(k,l))^2/(2*sigma_r^2)-((i-k)^2+(j-l)^2)/(2*sigma_d^2));
bm=bm+wf1;
mm=mm+wf2;
bflt(i,j)=bm/mm;
         end
     end
   end
end

end