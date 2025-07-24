// Quick Node.js script to generate the correct base64 encoded URI
const svg = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="500" height="500"><text x="0" y="15" fill="black">Hi! Your browser decoded this</text></svg>';

const base64Encoded = Buffer.from(svg).toString('base64');
const expectedUri = `data:image/svg+xml;base64,${base64Encoded}`;

console.log("SVG:", svg);
console.log("Base64 Encoded:", base64Encoded);
console.log("Expected URI:", expectedUri);
