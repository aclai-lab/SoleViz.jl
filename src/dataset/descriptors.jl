
"""
TODO: docs
# TODOs
- Support more than one descriptor in `descriptors`
- Support more than one function in `functions`
- Support `attribute_order` to order attributes in plots
- Implement `plot_dimesion` support 3D visualizations for windows
- Add more user-friendly interface for `windows` parameter
"""
function plotdescription(
	mfd::AbstractMultiFrameDataset;
	descriptors::AbstractVector{Symbol} = [:mean_m],
	functions::AbstractVector{Function} = Function[var],
	plot_kwargs::NamedTuple = NamedTuple(),
	attribute_order::Symbol = :keep, # :increasing, :decreasing # TODO
	layout::Symbol = :triangle, # :rectangle :pyramid
	plot_dimesion::Symbol = :twoD, # :threeD # TODO
	windows::AbstractVector{<:AbstractVector{<:AbstractVector{NTuple{3,Int}}}} =
		[[[(t,0,0) for i in 1:d] for d in dimension(mfd)] for t in [1,2,4,8]]
)
	# TODO: add assertions for Symbol kwargs

	# concat symbols
	cs(s1::Symbol, s2::Symbol) = Symbol(string(s1, "_", s2))
	# blank plots
	bp() = plot(; ticks = false, grid = false, axis = false)
	# count assigned values in vector
	countassigned(v::AbstractVector) = length(findall([isassigned(v, i) for i in 1:length(v)]))

	pyramid_base = maximum([t[1] for t in vcat(
		[d for w in windows for frame in w for d in w]...
	)])

	descriptions = Vector{Vector{DataFrame}}(undef, length(windows))

	Threads.@threads for (i, win) in collect(enumerate(windows))
		descriptions[i] = describe(mfd; desc = descriptors, t = win)
	end

	num_dimensional_frame = length(filter(x -> x isa Number && x > 0, dimension(mfd)))

	plot_pyramids = Vector{Matrix{Plots.Plot}}(undef, num_dimensional_frame)
	for (i_frame, dim) in enumerate(dimension(mfd))
		if dim isa Symbol
			continue
			# throw(ErrorException("`plotdescription` still not implemented for `$(dim)` frames"))
		elseif dim == 0
			continue
			# throw(ErrorException("`plotdescription` still not implemented for static frames"))
		else
			curr_pyramid = Matrix{Plots.Plot}(undef, length(windows), pyramid_base)
			for (i_win, win) in enumerate(windows)
				curr_frame_window = win[i_frame]
				d = SoleBase.SoleData.SoleDataset._stat_description(
					descriptions[i_win][i_frame];
					functions = functions
				)

				for chunk in 1:pyramid_base
					if chunk <= curr_frame_window[1][1] # curr_frame_window[1][1] is t
						curr_pyramid[i_win, chunk] =
							plot(
								collect(1:nrow(d)),
								# TODO: generalize on n-th function in functions
								# TODO: generalize on m-th descriptor in descriptors
								[v[chunk] for v in d[:,cs(descriptors[1], nameof(functions[1]))]],
								title = "$(chunk) / $(curr_frame_window[1][1])",
								xticks = (1:nrow(d), string.(d[:,1])),
								xrotation = 65
							)
					else
						# if layout == :triangle
							curr_pyramid[i_win, chunk] = bp()
						# end
					end
				end

			end
			plot_pyramids[i_frame] = curr_pyramid
		end
	end

	# if layout == :triangle
		return [plot(permutedims(pyr)..., layout = size(pyr)) for pyr in plot_pyramids]
	# elseif layout == :rectangle
	# 	res = Plots.Plot[]
	# 	for pyr in plot_pyramids
	# 		ts = [countassigned(pyr[i,:]) for i in 1:size(pyr, 1)]
	# 		l = @layout [ for ]
	# 		p = plot(
	# 			permutedims(pyr)...,
	# 			layout = size(pyr)
	# 		)
	# 		push!(res, p)
	# 	end
	# 	return res
	# end
end
