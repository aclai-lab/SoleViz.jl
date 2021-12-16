
"""
TODO: docs
# TODOs
- Support more than one descriptor in `descriptors`
- Support more than one function in `functions`
- Support `attribute_order` to order attributes in plots
- Implement `plot_dimension` support 3D visualizations for windows
- Add more user-friendly interface for `windows` parameter
"""
function plotdescription(
	mfd::AbstractMultiFrameDataset;
	descriptors::Union{AbstractVector{Symbol},AbstractDict{<:Any,<:AbstractVector{<:Symbol}}} = [:mean_m],
	functions::AbstractVector{Function} = Function[var],
	plot_kwargs::NamedTuple = NamedTuple(),
	attribute_order::Symbol = :keep, # :increasing, :decreasing # TODO
	layout::Symbol = :triangle, # :rectangle :pyramid
	plot_dimension::Symbol = :twoD, # :threeD # TODO
	windows::AbstractVector{<:AbstractVector{<:AbstractVector{NTuple{3,Int}}}} =
		[[[(t,0,0) for i in 1:d] for d in dimension(mfd)] for t in [1,2,4,8]],
	on_x_axis = :attributes, # :
	attribute_names = nothing,
	join_plots = [],
	descriptions::Union{AbstractVector{<:AbstractVector{<:AbstractDataFrame}},Nothing} = nothing # TODO: allow passing  already computed description
)
	@assert windows == [[[(1,0,0)]]] "$(windows)"
	@assert length(functions) == 1
	@assert on_x_axis in [:descriptors, :attributes]

	allowed_plot_dimensionts = [:twoD, :threeD]
	@assert plot_dimension in allowed_plot_dimensionts "Value `$(plot_dimension)` not " *
		"allowed: available are $(allowed_plot_dimensionts)"

	allowed_attribute_order = [:keep, :increasing, :decreasing]
	@assert attribute_order in allowed_attribute_order "Value `$(attribute_order)` not " *
		"allowed: available are $(allowed_attribute_order)"

	allowed_layout = [:triangle, :rectangle, :pyramid]
	@assert layout in allowed_layout "Value `$(layout)` not " *
		"allowed: available are $(allowed_layout)"

	# concat symbols
	cs(s1::Symbol, s2::Symbol) = Symbol(string(s1, "_", s2))
	# blank plots
	bp() = plot() # plot(; ticks = false, grid = true, axis = true)
	# count assigned values in vector
	countassigned(v::AbstractVector) = length(findall([isassigned(v, i) for i in 1:length(v)]))

	singleton_groups = false
	if isa(descriptors,AbstractVector{Symbol})
		singleton_groups = true
		descriptors = OrderedDict([string(descriptor) => [descriptor] for descriptor in descriptors])
	end
	# println(descriptors)
	# Number of plots at the pyramid's base
	pyramid_base_length = maximum([t[1] for t in vcat(
		[d for w in windows for frame in w for d in w]...
	)])

	num_dimensional_frame = length(filter(x -> x isa Number && x > 0, dimension(mfd)))
	n_attributes_per_frame = mfd[1:end].|>ncol
	max_n_attributes = (n_attributes_per_frame)|>maximum
	# println(num_dimensional_frame)

	stats = Vector{Vector{Vector{Vector{DataFrame}}}}(undef, length(descriptors))

	# Load stats
	for (i_descriptor_group,(descriptor_group_name,descrs)) in enumerate(descriptors)
		println("Describing $(descriptor_group_name)...")
		stats[i_descriptor_group] = Vector{Vector{DataFrame}}[]
		for (i_descriptor,descriptor) in enumerate(descrs)
			if !singleton_groups
				println("\t$(descriptor)...")
			end
			_stats = Vector{DataFrame}[]
			Threads.@threads for (i, win) in collect(enumerate(windows))
				# SoleBase.describeonm(description; desc = [descriptor])
				descriptions = SoleBase.describe(mfd; desc = [descriptor], t = win)
				d = [SoleBase.SoleData.SoleDataset._stat_description(
					description;
					functions = functions,
				) for description in descriptions]
				push!(_stats, d)
			end
			push!(stats[i_descriptor_group], _stats)
		end
	end
	
	if join_plots
		mega_plot = bp()
	else
		plot_pyramids = Array{Plots.Plot}(undef, length(windows), pyramid_base_length, (on_x_axis == :attributes ? length(descriptors) : max_n_attributes), num_dimensional_frame)
		for i in 1:length(plot_pyramids)
			plot_pyramids[i] = bp()
		end
	end

	# For each frame
	for (i_frame, dim) in enumerate(dimension(mfd))

		if dim isa Symbol
			# throw(ErrorException("`plotdescription` still not implemented for `$(dim)` frames"))
			continue
		elseif dim == 0
			# throw(ErrorException("`plotdescription` still not implemented for static frames"))
			continue
		end

		for (i_win, win) in enumerate(windows)

			curr_frame_window = win[i_frame]

			if on_x_axis == :attributes
				# For each descriptor
				for (i_descriptor_group,(descriptor_group_name,descrs)) in enumerate(descriptors)
					for (i_descriptor,descriptor) in enumerate(descrs)
						d = stats[i_descriptor_group][i_descriptor][i_win][i_frame];
						names = d[:,1]
						n_attributes = nrow(d)
						col = cs(descriptor, nameof(functions[1]))

						x = collect(1:n_attributes)
						ys = d[:,col]

						for i_chunk in 1:pyramid_base_length
							plot!((join_plots ? mega_plot : plot_pyramids[i_win, i_chunk, i_descriptor_group, num_dimensional_frame]),
								x,
								# TODO: generalize on n-th function in functions
								[v[i_chunk] for v in ys],
								labels = string(col),
								title = (join_plots ? "" : "$(descriptor_group_name)$(pyramid_base_length == 1 ? "" : " $(i_chunk) / $(curr_frame_window[1][1])")"),
								xticks = (1:length(x), string.(names)),
								xrotation = 65,
							)
						end
					end
				end
			elseif on_x_axis == :descriptors

				ds = [(stats[i_descriptor_group][i_descriptor][i_win][i_frame], descriptor) for (i_descriptor_group,(descriptor_group_name,descrs)) in enumerate(descriptors) for (i_descriptor,descriptor) in enumerate(descrs)];
				n_descriptors = length(ds)

				# println(ds)
				# For each attribute
				for i_attribute in 1:n_attributes_per_frame[i_frame]
					x = collect(1:n_descriptors)
					ys = [d[i_attribute, cs(descriptor, nameof(functions[1]))] for (d,descriptor) in ds]
					names = [cs(descriptor, nameof(functions[1])) for (d,descriptor) in ds]
					# println(ys)
					for i_chunk in 1:pyramid_base_length
						attribute_name = isnothing(attribute_names) ? "A$(i_attribute)" : attribute_names[i_attribute]
						plot!((join_plots ? mega_plot : plot_pyramids[i_win, i_chunk, i_attribute, num_dimensional_frame]),
							x,
							# TODO: generalize on n-th function in functions
							[v[i_chunk] for v in ys],
							labels = string("$(attribute_name)"),
							title = (join_plots ? "" : "$(attribute_name)$(pyramid_base_length == 1 ? "" : " $(i_chunk) / $(curr_frame_window[1][1])")"),
							xticks = (1:length(x), string.(names)),
							xrotation = 65,
						)
					end
				end
			end
		end
	end

	# if layout == :triangle
		# return [plot(permutedims(pyr)..., layout = size(pyr)) for pyr in plot_pyramids]
	return (join_plots ? [mega_plot] : plot_pyramids)
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
