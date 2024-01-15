%% 1. Histogram Streching
%1.
LUT1 = uint8(2*[0:255]);
LUT2 = uint8(floor((1/2)*[0:255]));
LUT3 = uint8(255-[0:255]);

t1 = (0.333) * [0:96];
t2 = ((192-32)/(200-96))*[97:200] -((192-32)/(200-96))*96+ 32;
t3 = ((255-192)/(255-200))*[201:255]-((255-192)/(255-200))*200 +192;
LUT4 = uint8(floor([t1 t2 t3]));

%2.
figure;
x = 0:255;
subplot(2, 2, 1); plot(x,LUT1)
subplot(2, 2, 2); plot(x,LUT2)
subplot(2, 2, 3); plot(x, LUT3)
subplot(2, 2, 4); plot(x, LUT4)

%3.
mat_x = imread('x-ray.png');
x1 = Image_Adjust_LUT(mat_x, LUT1);
x2 = Image_Adjust_LUT(mat_x, LUT2);
x3 = Image_Adjust_LUT(mat_x, LUT3);
x4 = Image_Adjust_LUT(mat_x, LUT4);

%4.
figure;
subplot(2, 2, 1); imshow(x1)
subplot(2, 2, 2); imshow(x2)
subplot(2, 2, 3); imshow(x3)
subplot(2, 2, 4); imshow(x4)
%% 2.Histogram Equalization
%1.
figure, subplot(1, 3, 1), imshow(x2)
subplot(1, 3, 2), imshow(x2, [])

%2.
x_2 = hequal(x2);
subplot(1, 3, 3), imshow(x_2)

%3.
% x2의 histogram을 보면, 0~255 중 0~130 정도의 낮은 pixel 값들로 분포되어있다. 
% 그렇기에 subplot 1에서는 이미지가 어둡게 보이게 된다.
% 이때, imshow에서 []을 이용한 subplot 2에서는 bone이 비교적 밝게 보이는데, []가 image matrix내의 min과 max를 기준으로
% 이미지를 보여주기에 밝게 보인다고 이해해볼 수 있겠다.
% 마지막으로 subplot3은 histogram equlization을 처리한 이미지인데, 앞서 말했듯이 0~130 정도에서만
% 분포되어있던 pixel value들을 HE를 통해, 0~255로 골고루 퍼지도록 처리되어 contrast가 좋아지게 되었다.
% 따라서 subplot 1과 비교하였을 때 매우 밝은 이미지를 관찰할 수 있다.
%% 3. Histogram Specification
%1.
x_ray2 = imread('x_ray2.png');

%2.
x_ray_HE = hequal(x_ray2);

%3.
figure; subplot(1, 2, 1), imshow(x_ray2)
subplot(1, 2, 2), imshow(x_ray_HE)

%4.
load('hist_desired.mat');

%5.
hist_xray2 = imhist(x_ray2);

%6.
sum_des = sum(hist_desired);
sum_xray = sum(hist_xray2);

pdf_desired = hist_desired/sum_des;
pdf_xray = hist_xray2/sum_xray;

cdf_desired = zeros(size(pdf_desired));
cdf_input = zeros(size(pdf_xray));

for i=1:size(pdf_desired, 2)-1
    cdf_desired(i+1) = cdf_desired(i) + pdf_desired(i);
end

for i=1:size(pdf_xray, 1)-1
    cdf_input(i+1) = cdf_input(i) + pdf_xray(i);
end

%7.
LUT = zeros(size(cdf_input));
for i=1:size(pdf_desired, 2)
    s = cdf_input(i);
    idx = find(abs(cdf_desired - s) < 0.0001);
    if size(idx, 2) > 1
        idx_real = round(mean(idx)); 
        % G(u)가 일대일대응 x -> 평균값으로 역함수 값 결정.
        LUT(i) = idx_real;
    else
        LUT(i) = idx;
    end
    LUT = uint8(LUT);
end

%8.
x_ray_HS = LUT(x_ray2 + 1);

%9.
figure;
subplot(1, 2, 1), imshow(x_ray_HE)
subplot(1, 2, 2), imshow(x_ray_HS)
% x_ray_HS의 image에서 bone이 비교적 확실하게 대비되어 선명하게 보인다.
%% Image Adjust Function.
function im_ad = Image_Adjust_LUT(im, LUT)
im_ad = zeros(size(im));
for i=1:size(im, 1)
    for j=1:size(im, 2)
        idx = im(i, j) + 1;
        ad = LUT(idx);
        im_ad(i, j) = im_ad(i, j) + ad;
    end
end
im_ad = uint8(im_ad);
end

% find -> for loop 1 times
%% Histogram equalization function.
function h_equal = hequal(im)
im_hst = imhist(im);
im_sum = sum(im_hst);

im_pdf = im_hst/im_sum;
im_cdf = zeros(size(im_pdf));

for i=1:size(im_pdf)-1
    im_cdf(i+1) = im_cdf(i) + im_pdf(i);
end

h_equa = uint8(round(255*im_cdf));
h_equal = Image_Adjust_LUT(im, h_equa);

end