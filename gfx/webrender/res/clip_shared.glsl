/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifdef WR_VERTEX_SHADER

#define SEGMENT_ALL         0
#define SEGMENT_CORNER_TL   1
#define SEGMENT_CORNER_TR   2
#define SEGMENT_CORNER_BL   3
#define SEGMENT_CORNER_BR   4

in int aClipRenderTaskAddress;
in int aClipLayerAddress;
in int aClipSegment;
in ivec4 aClipDataResourceAddress;

struct ClipMaskInstance {
    int render_task_address;
    int layer_address;
    int segment;
    ivec2 clip_data_address;
    ivec2 resource_address;
};

ClipMaskInstance fetch_clip_item() {
    ClipMaskInstance cmi;

    cmi.render_task_address = aClipRenderTaskAddress;
    cmi.layer_address = aClipLayerAddress;
    cmi.segment = aClipSegment;
    cmi.clip_data_address = aClipDataResourceAddress.xy;
    cmi.resource_address = aClipDataResourceAddress.zw;

    return cmi;
}

struct ClipVertexInfo {
    vec3 local_pos;
    vec2 screen_pos;
    RectWithSize clipped_local_rect;
};

RectWithSize intersect_rect(RectWithSize a, RectWithSize b) {
    vec4 p = clamp(vec4(a.p0, a.p0 + a.size), b.p0.xyxy, b.p0.xyxy + b.size.xyxy);
    return RectWithSize(p.xy, max(vec2(0.0), p.zw - p.xy));
}

// The transformed vertex function that always covers the whole clip area,
// which is the intersection of all clip instances of a given primitive
ClipVertexInfo write_clip_tile_vertex(RectWithSize local_clip_rect,
                                      Layer layer,
                                      ClipArea area,
                                      int segment) {
    vec2 outer_p0 = area.screen_origin_target_index.xy;
    vec2 outer_p1 = outer_p0 + area.task_bounds.zw - area.task_bounds.xy;
    vec2 inner_p0 = area.inner_rect.xy;
    vec2 inner_p1 = area.inner_rect.zw;

    vec2 p0, p1;
    switch (segment) {
        case SEGMENT_ALL:
            p0 = outer_p0;
            p1 = outer_p1;
            break;
        case SEGMENT_CORNER_TL:
            p0 = outer_p0;
            p1 = inner_p0;
            break;
        case SEGMENT_CORNER_BL:
            p0 = vec2(outer_p0.x, outer_p1.y);
            p1 = vec2(inner_p0.x, inner_p1.y);
            break;
        case SEGMENT_CORNER_TR:
            p0 = vec2(outer_p1.x, outer_p1.y);
            p1 = vec2(inner_p1.x, inner_p1.y);
            break;
        case SEGMENT_CORNER_BR:
            p0 = vec2(outer_p1.x, outer_p0.y);
            p1 = vec2(inner_p1.x, inner_p0.y);
            break;
    }

    vec2 actual_pos = mix(p0, p1, aPosition.xy);

    vec4 layer_pos = get_layer_pos(actual_pos / uDevicePixelRatio, layer);

    // compute the point position in side the layer, in CSS space
    vec2 vertex_pos = actual_pos + area.task_bounds.xy - area.screen_origin_target_index.xy;

    gl_Position = uTransform * vec4(vertex_pos, 0.0, 1);

    vLocalBounds = vec4(local_clip_rect.p0, local_clip_rect.p0 + local_clip_rect.size);

    ClipVertexInfo vi = ClipVertexInfo(layer_pos.xyw, actual_pos, local_clip_rect);
    return vi;
}

#endif //WR_VERTEX_SHADER
