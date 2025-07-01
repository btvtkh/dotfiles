local M = {}

function M.notch_top(cr, w, h, r)
	r = r or 10
	r = r > w/2 and w/2 or r
	r = r > h/2 and h/2 or r
	cr:move_to(0, 0)
	cr:arc(0, r, r, math.pi*3/2, math.pi*2)
	cr:arc_negative(r*2, h - r, r, math.pi, math.pi/2)
	cr:arc_negative(w - r*2, h - r, r, math.pi/2, math.pi*2)
	cr:arc(w, r, r, math.pi, math.pi*3/2)
	cr:close_path()
end

function M.notch_bottom(cr, w, h, r)
	r = r or 10
	r = r > w/2 and w/2 or r
	r = r > h/2 and h/2 or r
	cr:move_to(r, r)
	cr:arc(r*2, r, r, math.pi, math.pi*3/2)
	cr:arc(w - r*2, r, r, math.pi * 3/2, math.pi*2)
	cr:arc_negative(w, h - r, r, math.pi, math.pi/2)
	cr:arc_negative(0, h - r, r, math.pi/2, math.pi*2)
	cr:close_path()
end

function M.notch_left(cr, w, h, r)
	r = r or 10
	r = r > w/2 and w/2 or r
	r = r > h/2 and h/2 or r
	cr:move_to(0, 0)
	cr:arc_negative(r, 0, r, math.pi, math.pi/2)
	cr:arc(w - r, r*2, r, math.pi*3/2, math.pi*2)
	cr:arc(w - r, h - r*2, r, math.pi*2, math.pi/2)
	cr:arc_negative(r, h, r, math.pi*3/2, math.pi)
	cr:close_path()
end

function M.notch_right(cr, w, h, r)
	r = r or 10
	r = r > w/2 and w/2 or r
	r = r > h/2 and h/2 or r
	cr:move_to(r, r)
	cr:arc_negative(r, r*2, r, math.pi*3/2, math.pi)
	cr:arc_negative(r, h - r*2, r, math.pi, math.pi/2)
	cr:arc(w - r, h, r, math.pi*3/2, math.pi*2)
	cr:arc(w - r, 0, r, math.pi*2, math.pi/2)
	cr:close_path()
end

return M
