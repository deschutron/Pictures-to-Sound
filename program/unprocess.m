function unprocess(filename)
	tau = 2*pi;

	% load the image file
	image = imread(filename);

	ident = 256
	image_class = class(image(1,1,1))
	%if (image_class == double)
	%	ident = 1;
	%elseif (image_class == uint16)
	%	ident = 65536;
	%elseif (image_class == uint8)
	%	ident = 256;
	%elseif (image_class == logical)
	%	ident = 1;
	%endif
	r = double(image(:,:,1)) / ident;
	if (size(image, 3) == 1)
		g = r;
		b = r;
	else
		g = double(image(:,:,2)) / ident;
		b = double(image(:,:,3)) / ident;
	endif
	% % pull the sub-byte info out of r
	%subby = mod(r, 8);
	%r -= subby;
	%r *= 255 / 252;

	%y = .299 * r + .587 * g;
	%y = 0.212568 

	% scale y to [0, 1)
	%y /= 256 * (.299 + .587);

	% get (y, cr, cb)
	y  =  .212568 * r + .715236 * g + .072196 * b;
	cr =  .499946 * r - .454155 * g - .045791 * b;
	cb = -.114559 * r - .385338 * g + .499897 * b;
	% adjust (cr, cb) according to the brightness value
	cr = cr ./ y;
	cb = cb ./ y;
	cr(isnan(cr)) = 0;
	cb(isnan(cb)) = 0;
	printf("r nan count ==  %d\n", sum(sum(isnan(r))));
	printf("g nan count ==  %d\n", sum(sum(isnan(g))));
	printf("b nan count ==  %d\n", sum(sum(isnan(b))));
	printf("y nan count ==  %d\n", sum(sum(isnan(y))));
	printf("cr nan count == %d\n", sum(sum(isnan(cr))));
	printf("cb nan count == %d\n", sum(sum(isnan(cb))));

	%re = floor(y * 1024) / 1024;
	%re += subby / 256 / 16;
	mag = y;
	%ang = arg(cr + cb*1i);
	%ang = atan(cb / cr);
	n_c = size(mag, 1);
	ang = zeros(size(mag));
	for index = [1:n_c]
		ang(index,:) = arg(cr(index,:) + cb(index,:)*1i);
		if (size(ang(index,:)) == 0)
			"ang strip size is zero"
		endif
	endfor

	%im = b / 256;

	%re = 2 * (re - .5);
	%im = 2 * (im - .5);

	%fftStrips = complex(re) + complex(im) * 1i;
	%mag = (0 .* mag) .+ .5;
	%ang = 0 .* ang;
	fftStrips = mag .* exp(ang * 1i);
	%fftStrips = mag .* (cos(ang) + 1i * sin(ang));
	%fftStrips = (ang + tau/2)/tau;
	%ang
	%fftStrips = ones(size(mag)) / 2;

	fftMax = max(max(abs(fftStrips)))

	% adjust the pixel brightnesses
	fftStrips = fftStrips .* abs(fftStrips);
	n = size(fftStrips, 1);
	%fftStrips *= 32;
	for i = [1:n]
		fftStrips(i, :) = fftStrips(i, :) / 2^(-6.5 * (i / n) - 2.75);
	endfor
	%fftStrips(n, :) /= 2;

	% put the top half back on
	n_2 = size(fftStrips)(1);
	topHalf = conj(flipud(fftStrips(2:(n_2 - 1), :)));
	fftStrips = [fftStrips(n_2, :); topHalf; fftStrips(1:(n_2-1), :)];

	% report dimensions of fftStrips
	size(fftStrips)

	% get the sound chunks
	soundChunks = ifft(fftStrips);

	maxSoundVal = max(max(abs(soundChunks)))
	soundChunksSize = size(soundChunks)

	% reduce clicks at sound-chunk boundaries
	%soundChunks(soundChunksSize(1), :) += soundChunks(soundChunksSize(1) - 1, :);
	%soundChunks(soundChunksSize(1), :) /= 2;
	for i = [2:soundChunksSize(2)]
		soundChunks(1, i) = (soundChunks(1, i) + soundChunks(soundChunksSize(1), i - 1)) / 2;
		%soundChunks(2, i) = (3 * soundChunks(2, i) + soundChunks(soundChunksSize(1), i - 1)) / 4;
	endfor

	sound = reshape(real(soundChunks), soundChunksSize(1) * soundChunksSize(2), 1);
	estSampleRate = soundChunksSize(1) * 32
	sampleRate = estSampleRate;
	% save the sound file
	wavwrite(sound, sampleRate, [filename ".wav"]);
endfunction
