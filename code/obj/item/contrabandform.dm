/obj/item/sticker/postit/contraband_paper
	name = "contraband assessment form"
	icon = 'icons/obj/writing.dmi'
	icon_state = "artifact_form" //placeholder until sprited
	desc = "A standardized form for documenting contraband attained via security, with some extra strong adhesive on the back."
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA | PIXEL_SCALE
	var/contrabandName = ""
	var/contrabandOrigin = ""
	var/contrabandType = ""
	var/contrabandValue = ""
	var/contrabandDetails = ""
	var/list/crossed = list()

	//TODO add random renaming chance to contraband
	// proc/checkArtifactVars(obj/O)
	// 	// ok, let's make a name
	// 	// start with obscured name
	// 	src.contrabandName = O.real_name
	// 	// get an instance of the artifact origin
	// 	for(var/datum/artifact_origin/origin as() in artifact_controls.artifact_origins)
	// 		if(origin.type_name == src.artifactOrigin)
	// 			// have we already generated a name for that origin?
	// 			// the actual name with the actual origin should be in the list by default
	// 			if(!A.used_names[src.artifactOrigin])
	// 				// no, generate new one and store it
	// 				src.contrabandName = origin.generate_name()
	// 				A.used_names[src.artifactOrigin] = src.contrabandName
	// 			else
	// 				// yes, use it
	// 				src.contrabandName = A.used_names[src.artifactOrigin]
	// 			break

	// 	// all correct, let's set the name!
	// 	O.real_name = src.contrabandName
	// 	O.UpdateName()

	attack_hand(mob/user)
		var/obj/attachedobj = src.attached
		if(istype(attachedobj) && attachedobj.artifact) // touch artifact we are attached to
			src.attached.Attackhand(user)
			user.lastattacked = get_weakref(user)
		else // do sticker things
			..()

	stick_to(var/atom/A, var/pox, var/poy, user, silent = FALSE)
		. = ..()
		APPLY_ATOM_PROPERTY(A, PROP_MOVABLE_CONTRABAND_OVERRIDE, src, contrabandValue)
		if(ismovable(A) && !A.GetComponent(/datum/component/contraband))
			A.AddComponent(/datum/component/contraband, 0, 0)
		SEND_SIGNAL(src.attached, COMSIG_MOVABLE_CONTRABAND_CHANGED, TRUE)
		if(isobj(A))
			src.updateTypeLabel(src.contrabandType)

	attackby(obj/item/W, mob/living/user)
		if(istype(W, /obj/item/pen)) // write on it
			ui_interact(user)
		else if((iscuttingtool(W) || issnippingtool(W)) && user.a_intent == INTENT_HELP && src.attached && !ismob(src.attached)) // remove attached paper from contraband
			boutput(user, "You manage to scrape \the [src] off of \the [src.attached].")
			src.remove_from_attached()
			src.add_fingerprint(user)
			user.put_in_hand_or_drop(src)
		else
			var/obj/attachedobj = src.attached
			if(istype(attachedobj) && attachedobj.artifact) // hit contraband we are attached to
				src.attached.Attackby(W, user)
				user.lastattacked = get_weakref(user)
			else // just sticker things
				..()

	get_desc()
		. = src.contrabandType!=""?"This one seems to be describing a [src.contrabandType] contraband with a [src.contrabandValue] rating.":""

	examine(mob/user)
		. = ..()
		ui_interact(user)

	attack_self(mob/user)
		ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ContrabandPaper")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"allContrabandValues" = list("zero", "one", "two", "three")
			// "allContrabandsValues" = artifact_controls.artifact_origin_names
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		if (!usr.find_type_in_hand(/obj/item/pen))
			boutput(usr, "You can't write without a pen!")
			return FALSE

		var/obj/O = null
		if(isobj(src.loc))
			O = src.loc
		switch(action)
			if("origin")
				if (contrabandOrigin == params["newOrigin"])
					contrabandOrigin = ""
					crossed += params["newOrigin"]
				else
					crossed -= params["newOrigin"]
					contrabandOrigin = params["newOrigin"]
			if("value")
				if (contrabandValue == params["newValue"])
					contrabandValue = ""
					crossed += params["newValue"]
				else
					crossed -= params["newValue"]
					contrabandValue = params["newValue"]
			if("type")
				if (contrabandType == params["newType"])
					removeTypeLabel()
					contrabandType = ""
					crossed += params["newType"]
				else
					crossed -= params["newType"]
					src.updateTypeLabel(params["newType"])
					contrabandType = params["newType"]
			if("detail")
				contrabandDetails = params["newDetail"]
		. = TRUE

	ui_data(mob/user)
		. = list(
			"contrabandName" = contrabandName,
			"contrabandOrigin" = contrabandOrigin,
			"contrabandValue" = contrabandValue,
			"contrabandType" = contrabandType,
			"contrabandDetails" = contrabandDetails,
			"crossed" = crossed
		)

	remove_from_attached(do_loc = TRUE)
		// attempting to reset contraband level when form is removed
		REMOVE_ATOM_PROPERTY(src.attached, PROP_MOVABLE_CONTRABAND_OVERRIDE, src)
		SEND_SIGNAL(src.attached, COMSIG_MOVABLE_CONTRABAND_CHANGED, TRUE)
		src.removeTypeLabel()
		. = ..()

//TODO review about adding type name/removing type name
	/// updates the label that shows what type the artifact supposedly is
	proc/updateTypeLabel(var/newtype)
		// nothing to set, so no need!
		if(newtype == "")
			return
		if(isobj(src.attached))
			var/obj/O = src.attached
			O.remove_suffixes("\[[src.contrabandType]\]")
			O.name_suffix("\[[newtype]\]")
			O.UpdateName()

	/// removes the label that shows what type the artifact supposedly is
	proc/removeTypeLabel()
		if(isobj(src.attached))
			var/obj/O = src.attached
			O.remove_suffixes("\[[src.contrabandType]\]")
			O.UpdateName()
