function process (filename)
	% load the sound file
	[sound, fs, bitDepth] = wavread(filename);
	 % S = the strip length
	S = floor(fs / 32 + .5)
	bitDepth
	if size(sound, 2) > 1
		sound = mean(sound, 2);
	endif

	% split the sound file into chunks
	printf("now %f\n", mod(now, 1/24)*24*60);
	N = size(sound)(1)
	 % pad the array
	paddedN = S * ceil(N / S);
	paddedSound = postpad(sound, paddedN);
	 % do the split
	soundChunks = reshape(paddedSound, S, paddedN / S);
	size(soundChunks)
	"max sound value:"
	max(max(abs(soundChunks)))

	% get the fft of the chunk
	fftStrips = fft(soundChunks);
	% report dimensions of fftStrips
	size(fftStrips)

	% cut the top half off fftStrips
	%fftStrips = fftStrips(ceil(size(fftStrips)(1)/2+1):size(fftStrips), :);
	n = size(fftStrips)(1);
	half_n = floor((n + 1)/2);
	fftStrips = fftStrips([(half_n + 1):n 1], :);

	fftMax = max(max(abs(fftStrips)))
	fftMin = min(min(abs(fftStrips)))

	% adjust the pixel brightnesses
	n = size(fftStrips, 1);
	%fftStrips /= 32;
	for i = [1:n]
		fftStrips(i, :) = fftStrips(i, :) * 2^(-6.5 * (i / n) - 2.75);
	endfor
	%fftStrips(n, :) *= 2;
	fftStrips = fftStrips ./ sqrt(abs(fftStrips));

	% convert the fft to image data, the result is an "image strip"
	printf("now %f\n", mod(now, 1/24)*24*60);
	maxRe = max(max(abs(real(fftStrips))))
	 % get the magnitude and angle
	mag = abs(fftStrips);
	ang = arg(fftStrips);
	maxMag = max(max(mag))
	%maxAng = max(max(ang))
	%minAng = min(min(ang))

	 % set Y, C_R and C_B
	y = mag;
	cr = cos(ang);
	cb = sin(ang);
	cr = cr .* mag;
	cb = cb .* mag;

	 % map it into RGB colour space
	r = y + 1.5750 * cr     -  .0001515 * cb;
	g = y -  .46810 * cr    -  .1873 * cb;
	b = y +  .0001057 * cr + 1.856 * cb;

	image = cat(3, r, g, b);

	% save the image
	printf("now %f\n", mod(now, 1/24)*24*60);
	%saveimage([filename ".ppm"], image, "ppm");
	imwrite(image, [filename ".png"], "png", "BitDepth", 16);
endfunction
