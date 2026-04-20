
% TODO:
% 1) replace fig to Axes
% 2) add smart lim

classdef DWM_graph < handle

    methods (Access = public)
        function obj = DWM_graph(fig)
            obj.fig = fig;
            figure(obj.fig);
            obj.clear;
        end

%         function delete(obj)
%             close(obj.fig)
%         end

        function lines = get_lines(obj)
            Axes = get_ax_from_fig(obj.fig);
            lines = get_line_from_ax(Axes);
%             lines = Axes.Children;
        end

        function set_props_to_active(obj, color, style, width)
            obj.active_line.Color = color;
            obj.active_line.LineStyle = style;
            obj.active_line.LineWidth = width;
        end

        function add_new_line(obj, color, style, width)
            Axes = get_ax_from_fig(obj.fig);
            if isempty(Axes)
                Axes = axes(obj.fig);
            end
            obj.active_line = line_factory(color, style, width, Axes);
        end

        function update_last(obj, x, y)
            obj.active_line.XData = x;
            obj.active_line.YData = y;
            drawnow;
        end

        function clear(obj)
            try
            Axes = get_ax_from_fig(obj.fig);
            delete(Axes);
            catch
            end
            axes(obj.fig);
        end

        function gray_all(obj)
            Axes = get_ax_from_fig(obj.fig);
            if ~isempty(Axes)
%                 lines = Axes.Children;
                lines = get_line_from_ax(Axes);
                for i = 1:numel(lines)
                    color = lines(i).Color;
                    color = rgb2gray(color);
                    lines(i).Color = color;
                    lines(i).LineWidth = 0.8;
                    sparse_lines(lines(i));
                end
                drawnow
            end
        end

        function add_new_and_shadow_prev(obj, color, style, width)
            obj.gray_all();
            obj.add_new_line(color, style, width);
        end

    end

    methods (Access = private)

        
    end

    properties (Access = private)
        fig;
        active_line;
    end

end






function line_out = line_factory(color, style, width, Axes)
x = xlim;
y = ylim;
line_out = line(Axes, [x(1) x(1)], [y(1) y(1)], 'color', color, ...
    'linestyle', style, 'linewidth', width);
end


function [x, y] = sparse_data(x, y)
    while numel(x) > 4000
        x2 = x(1:2:end);
        y2 = y(1:2:end);
        x2(end) = x(end);
        y2(end) = y(end);
        x = x2;
        y = y2;
    end
end


function sparse_lines(line)
x = line.XData;
y = line.YData;
[x, y] = sparse_data(x, y);
line.XData = x;
line.YData = y;
end


function ax = get_ax_from_fig(fig)

Ch_fig = fig.Children;

% clc
out_i = [];
for i = 1:numel(Ch_fig)
%     disp([num2str(i) ' : ' class(Ch_fig(i))])
    if class(Ch_fig(i)) == "matlab.graphics.axis.Axes"
        out_i = [out_i i];
    end
end

if isempty(out_i)
    error('no axes in figure')
elseif numel(out_i) > 1
    error('too many axes in figure (more than one)')
else
    ax = Ch_fig(out_i);
end

end


function lines = get_line_from_ax(Ax)

Ch_ax = Ax.Children;

% clc
out_i = [];
for i = 1:numel(Ch_ax)
%     disp([num2str(i) ' : ' class(Ch_ax(i))])
    if class(Ch_ax(i)) == "matlab.graphics.chart.primitive.Line"
        out_i = [out_i i];
    end
end

lines = Ch_ax(out_i);

end


