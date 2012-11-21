#SVGen
SVGen is a web service (written in CoffeeScript, flying with node.js) to generate spinning ajax loader animations serving freshly baked, super tiny and fully scalable SVGs. So you really don't need to use "lightweight" JavaScript libraries or unscalable, not-quite transparent GIFs.

[Try SVGen @heroku](http://svgen.herokuapp.com/)

## Why SVG?
SVG images are quite small and fully scalable as they are vector based. A simple, animated SVG spinner with 12 dots weights about 750 bytes (gzipped ~350 bytes) and looks nice at any resolution. For comparison, the spin.js script weights more than 4 times as much. And why should you use a script to generate the same spinner all the time – again and again.

## Browser Support:

If you don't have to support for every crappy web browser like IE6-8 there is no reason not to use SVG spinning animations. For ancient technologies you can always include a fallback png/gif or whatever you want.

**SVG is supported by the following browsers:**

* IE 9+
* Firefox 4+
* Chrome 4+
* Safari (3.2+ partial, 5+ full)
* Opera 9.5+
* iOS (3.2+ partial, 4.2+ full)
* Opera Mini 5+
* Android Browser 3+
* Blackberry Browser 7+
* Opera Mini 10+
* Chrome for Android 18+
* Firefox for Android 15+

(see: [Can I Use: SVG in CSS backgrounds](http://caniuse.com/#feat=svg-css))