void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 ndc = uv * 2.0 - 1.0;
    float aspect = iResolution.x / iResolution.y;
    ndc.x *= aspect;

    vec2 mouse = iMouse.xy / iResolution.xy;
    if(iMouse.z <= 0.0) mouse = vec2(0.5, 0.4);
    float angleX = (mouse.x - 0.5) * 6.28;
    vec3 ro = vec3(4.0 * sin(angleX), 1.5, 4.0 * cos(angleX));
    vec3 target = vec3(0.0, 0.0, 0.0);
    vec3 ww = normalize(target - ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));
    vec3 rd = normalize(ndc.x * uu + ndc.y * vv + 1.5 * ww);

    vec3 finalColor = vec3(0.0);
    float reflectionWeight = 1.0;
    vec3 lightPos = vec3(2.0, 4.0, 2.0);

    for (int i = 0; i < 3; i++) {
        float t = 1e10;
        vec3 normal, hitPos, objCol;
        bool hit = false;
        bool isGlass = false;

        // Kure 1 (Sabit)
        vec3 s1P = vec3(-1.0, 0.3, 0.0);
        float s1R = 0.8;
        vec3 oc1 = ro - s1P;
        float b1 = 2.0 * dot(oc1, rd), c1 = dot(oc1, oc1) - s1R*s1R, d1 = b1*b1 - 4.0*c1;
        if(d1 > 0.0) {
            float t1 = (-b1 - sqrt(d1)) / 2.0;
            if(t1 > 0.001 && t1 < t) {
                t = t1; hitPos = ro + t * rd; normal = normalize(hitPos - s1P);
                objCol = vec3(0.1, 0.6, 0.9); hit = true; isGlass = true;
            }
        }

        // Kure 2 (Sabit)
        vec3 s2P = vec3(1.0, 0.3, 0.0);
        float s2R = 0.8;
        vec3 oc2 = ro - s2P;
        float b2 = 2.0 * dot(oc2, rd), c2 = dot(oc2, oc2) - s2R*s2R, d2 = b2*b2 - 4.0*c2;
        if(d2 > 0.0) {
            float t2 = (-b2 - sqrt(d2)) / 2.0;
            if(t2 > 0.001 && t2 < t) {
                t = t2; hitPos = ro + t * rd; normal = normalize(hitPos - s2P);
                objCol = vec3(0.9, 0.3, 0.3); hit = true; isGlass = true;
            }
        }


        float tP = -(ro.y + 0.5) / rd.y;
        if (tP > 0.001 && tP < t) {
            t = tP; hitPos = ro + t * rd; normal = vec3(0.0, 1.0, 0.0);
            float f = mod(floor(hitPos.x) + floor(hitPos.z), 2.0);
            objCol = mix(vec3(0.1), vec3(0.9), f); hit = true; isGlass = false;
        }

        if (!hit) {
            finalColor += vec3(0.5, 0.7, 1.0) * reflectionWeight;
            break;
        }


        vec3 L = normalize(lightPos - hitPos);
        float shadow = 1.0;
        

        vec3 soc1 = (hitPos + normal * 0.01) - s1P;
        if(pow(dot(soc1, L), 2.0) - (dot(soc1, soc1) - s1R*s1R) > 0.0) shadow = 0.2;
        // Kure 2-nin kolgesi
        vec3 soc2 = (hitPos + normal * 0.01) - s2P;
        if(pow(dot(soc2, L), 2.0) - (dot(soc2, soc2) - s2R*s2R) > 0.0) shadow = 0.2;

        float diff = max(dot(normal, L), 0.0);
        

        finalColor += (objCol * diff * shadow + 0.1) * reflectionWeight;

        if(isGlass) {
            reflectionWeight *= 0.5; 
            rd = refract(rd, normal, 1.0/1.2); 
            ro = hitPos - normal * 0.01;
        } else {
            reflectionWeight *= 0.4; 
            rd = reflect(rd, normal);
            ro = hitPos + normal * 0.01;
        }
    }

    fragColor = vec4(finalColor, 1.0);
}
