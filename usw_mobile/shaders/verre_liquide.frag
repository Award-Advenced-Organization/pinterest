// Le verre liquide facon iOS : ce qui passe derriere le verre est
// legerement depoli, et se courbe pres du bord comme a travers une lentille
// (le biseau refracte). Applique par un BackdropFilter (ImageFilter.shader).
#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uTaille;   // la taille de la texture du fond (donnee par le moteur)
uniform vec4 uRect;     // le verre : x, y, largeur, hauteur, en pixels
uniform float uRayon;   // le rayon des coins, en pixels
uniform float uBiseau;  // la largeur du bord qui refracte, en pixels
uniform float uForce;   // le deplacement maximal au bord, en pixels
uniform float uDepoli;  // l ecart des echantillons du depoli, en pixels

uniform sampler2D uFond;

out vec4 fragColor;

float rectangleArrondi(vec2 p, vec2 demi, float r) {
  vec2 q = abs(p) - demi + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec4 lire(vec2 px) {
  vec2 uv = clamp(px / uTaille, 0.0, 1.0);
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(uFond, uv);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 demi = uRect.zw * 0.5;
  vec2 local = p - (uRect.xy + demi);
  float r = min(uRayon, min(demi.x, demi.y));
  float d = rectangleArrondi(local, demi, r);

  // La normale du bord, par la pente de la distance.
  vec2 e = vec2(1.0, 0.0);
  vec2 n = vec2(
    rectangleArrondi(local + e.xy, demi, r) - rectangleArrondi(local - e.xy, demi, r),
    rectangleArrondi(local + e.yx, demi, r) - rectangleArrondi(local - e.yx, demi, r));
  n = n / max(length(n), 1e-4);

  // 0 au coeur du verre, 1 sur le bord : la lentille agit surtout au bord.
  float t = clamp(1.0 + d / uBiseau, 0.0, 1.0);
  vec2 source = p - n * uForce * t * t * t;

  // Le depoli leger : neuf echantillons ponderes autour du point.
  vec4 c = vec4(0.0);
  float poids = 0.0;
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      float k = (i == 0 && j == 0) ? 4.0 : ((i == 0 || j == 0) ? 2.0 : 1.0);
      c += lire(source + vec2(float(i), float(j)) * uDepoli) * k;
      poids += k;
    }
  }
  fragColor = c / poids;
}
