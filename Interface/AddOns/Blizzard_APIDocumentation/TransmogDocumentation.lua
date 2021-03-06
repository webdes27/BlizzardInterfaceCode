local Transmog =
{
	Name = "Transmogrify",
	Type = "System",
	Namespace = "C_Transmog",

	Functions =
	{
		{
			Name = "GetCreatureDisplayIDForSource",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureDisplayID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSlotForInventoryType",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventoryType", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "TransmogCollectionCameraUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_CAMERA_UPDATE",
		},
		{
			Name = "TransmogCollectionItemUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_ITEM_UPDATE",
		},
		{
			Name = "TransmogCollectionSourceAdded",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_SOURCE_ADDED",
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogCollectionSourceRemoved",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_SOURCE_REMOVED",
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogCollectionUpdated",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_UPDATED",
			Payload =
			{
				{ Name = "collectionIndex", Type = "number", Nilable = true },
				{ Name = "modID", Type = "number", Nilable = true },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "reason", Type = "string", Nilable = true },
			},
		},
		{
			Name = "TransmogSearchUpdated",
			Type = "Event",
			LiteralName = "TRANSMOG_SEARCH_UPDATED",
			Payload =
			{
				{ Name = "searchType", Type = "number", Nilable = false },
				{ Name = "collectionType", Type = "number", Nilable = true },
			},
		},
		{
			Name = "TransmogSetsUpdateFavorite",
			Type = "Event",
			LiteralName = "TRANSMOG_SETS_UPDATE_FAVORITE",
		},
		{
			Name = "TransmogSourceCollectabilityUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_SOURCE_COLLECTABILITY_UPDATE",
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
				{ Name = "collectable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TransmogrifyClose",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_CLOSE",
		},
		{
			Name = "TransmogrifyItemUpdate",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_ITEM_UPDATE",
		},
		{
			Name = "TransmogrifyOpen",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_OPEN",
		},
		{
			Name = "TransmogrifySuccess",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_SUCCESS",
			Payload =
			{
				{ Name = "invSlot", Type = "number", Nilable = false },
				{ Name = "transmogType", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogrifyUpdate",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_UPDATE",
			Payload =
			{
				{ Name = "slotID", Type = "number", Nilable = true },
				{ Name = "transmogType", Type = "number", Nilable = true },
				{ Name = "action", Type = "string", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "TransmogSource",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "None", Type = "TransmogSource", EnumValue = 0 },
				{ Name = "JournalEncounter", Type = "TransmogSource", EnumValue = 1 },
				{ Name = "Quest", Type = "TransmogSource", EnumValue = 2 },
				{ Name = "Vendor", Type = "TransmogSource", EnumValue = 3 },
				{ Name = "WorldDrop", Type = "TransmogSource", EnumValue = 4 },
				{ Name = "HiddenUntilCollected", Type = "TransmogSource", EnumValue = 5 },
				{ Name = "CantCollect", Type = "TransmogSource", EnumValue = 6 },
				{ Name = "Achievement", Type = "TransmogSource", EnumValue = 7 },
				{ Name = "Profession", Type = "TransmogSource", EnumValue = 8 },
				{ Name = "NotValidForTransmog", Type = "TransmogSource", EnumValue = 9 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Transmog);