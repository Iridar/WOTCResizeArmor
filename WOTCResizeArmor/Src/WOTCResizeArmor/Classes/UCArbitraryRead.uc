class UCArbitraryRead extends Object;

// This class is made by robojumper, it commits some kind of street magic to achieve reflection
// context https://discord.com/channels/165245941664710656/167912351763398657/1000043849911124069

const UOBJECT_PROPERTIES_SIZE = 96;

struct ObjectPtr {
	var int Lo, Hi;
};

struct ExposedName {
	var int Index, Suffix;
};

var name NameVar;
var int IntVar; // UOBJECT_PROPERTIES_SIZE + 0
var byte ByteVar; // UOBJECT_PROPERTIES_SIZE + 4


// TODO: This is massively inefficient but compiles in one go.
// Investigate using a script package with intentionally mismatched
// declarations vs what's actually included.

delegate UCArbitraryRead Del_PtrToObject(ObjectPtr ptr);
delegate ObjectPtr Del_ObjectToPtr(Object obj);
delegate ExposedName Del_ExposeName(name nm);
delegate Object Del_ObjectId(Object obj);

private static function Object ObjectId(Object obj) {
	return obj;
}

function ExposedName ExposeName(name nm) {
    local delegate<Del_ExposeName> del;
	local delegate<Del_ObjectId> del2;
    del2 = ObjectId;
	del = del2;
    return del(nm);
}

function ObjectPtr ObjectToPtr(Object obj) {
    local delegate<Del_ObjectToPtr> del;
	local delegate<Del_ObjectId> del2;
    del2 = ObjectId;
	del = del2;
    return del(obj);
}

function UCArbitraryRead PtrToObject(ObjectPtr ptr) {
	local delegate<Del_PtrToObject> del;
	local delegate<Del_ObjectId> del2;
	del2 = ObjectId;
    del = del2;
    return del(ptr);
}

function int ReadIntAt(ObjectPtr Ptr, int offset) {
	local UCArbitraryRead Back;
	Ptr = SubFromPtr(Ptr, UOBJECT_PROPERTIES_SIZE);
	Ptr = AddToPtr(Ptr, offset);
	Back = PtrToObject(Ptr);
	return Back.IntVar;
	
}

static function string FormatPtr(ObjectPtr Ptr) {
	return ToHex(Ptr.Hi) $ ToHex(Ptr.Lo);
}

/// Implement 64-bit unsigned arithmetic with two 32-bit signed integers

// Requires offset >= 0
static function ObjectPtr AddToPtr(ObjectPtr Ptr, int Offset) {
    if (Ptr.Lo >= 0 || Ptr.Lo == 0x80000000) {
		// Per condition, Lo in [0, 2^31].
		// Per precondition, Offset in [0, 2^31-1].
		// Thus result cannot overflow 2^32-1 because 2^31+2^31-1 = 3^32-1.
	    Ptr.Lo += Offset;
	} else {
		Ptr.Lo += Offset;
		// If our sign changed from negative to positive, we overflowed 0xFFFFFFFF,
		// so we must add 1 to Hi.
		if (Ptr.Lo >= 0) {
			Ptr.Hi += 1;
		}
	}

	return Ptr;
}

// Requires offset >= 0
static function ObjectPtr SubFromPtr(ObjectPtr Ptr, int Offset) {
    if (Ptr.Lo < 0 || Ptr.Lo == 0x7FFFFFFF) {
		// Per condition, Lo in [2^31-1, 2^32-1].
		// Per precondition, Offset in [0, 2^31-1].
		// Thus result cannot overflow 0 because 2^31-1 - 2^31-1 = 0.
	    Ptr.Lo -= Offset;
	} else {
		Ptr.Lo -= Offset;
		// If our sign changed from positive to negative, we borrowed from Hi,
		// so sub one.
		if (Ptr.Lo < 0) {
			Ptr.Hi -= 1;
		}
	}

	return Ptr;
}
