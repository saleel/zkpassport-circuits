/**
* The standards for passports and any other travel documents, electronic or not,
* are defined in the ICAO (International Civil Aviation Organization) 9303 document available here:
* https://www.icao.int/publications/pages/publication.aspx?docnum=9303
*/

/**
* The structure of the MRZ is well defined and standardized by the ICAO
* so the index will always be the same for every passport
* c.f. ICAO 9303-4, Appendix B
*/

// The following constants define the indices of the information
// we need to generate various proofs of identity from the MRZ
// The structure of the MRZ is slightly different between passports
// and ID cards so we need to define indices for both types

// Index for the country of issuance of the passport
pub global PASSPORT_MRZ_COUNTRY_INDEX: u32 = 2;
// Index for the three letter code of the country of citizenship
// Note that the first three letter code (index 2) in the MRZ is the country of issuance
// not citizenship. It is important to keep in mind for residence permits
// where the issuing country differs from the citizenship country
pub global PASSPORT_MRZ_NATIONALITY_INDEX: u32 = 54;
// Index for the gender of the passport holder (M, F or < if unspecified)
pub global PASSPORT_MRZ_GENDER_INDEX: u32 = 64;
// Index for the date of expiry (YYMMDD)
pub global PASSPORT_MRZ_EXPIRY_DATE_INDEX: u32 = 65;
// Index for the date of birth (YYMMDD) in TD1 (i.e. passport) MRZ
pub global PASSPORT_MRZ_BIRTHDATE_INDEX: u32 = 57;
// Index for the document number in the MRZ
pub global PASSPORT_MRZ_DOCUMENT_NUMBER_INDEX: u32 = 44;
// Index for the document type in the MRZ
pub global PASSPORT_MRZ_DOCUMENT_TYPE_INDEX: u32 = 0;
// Index for the name of the passport holder
pub global PASSPORT_MRZ_NAME_INDEX: u32 = 5;
// Length of the MRZ on a passport
pub global PASSPORT_MRZ_LENGTH: u32 = 88;

// Index for the country of issuance of the ID card
pub global ID_CARD_MRZ_COUNTRY_INDEX: u32 = 2;
// Note that the first three letter code (index 2) in the MRZ is the country of issuance
// not citizenship. It is important to keep in mind for residence permits
// where the issuing country differs from the citizenship country
pub global ID_CARD_MRZ_NATIONALITY_INDEX: u32 = 45;
// Index for the gender of the passport holder (M, F or < if unspecified)
pub global ID_CARD_MRZ_GENDER_INDEX: u32 = 37;
// Index for the date of expiry (YYMMDD)
pub global ID_CARD_MRZ_EXPIRY_DATE_INDEX: u32 = 38;
// Index for the date of birth (YYMMDD) in TD3 (i.e. ID cards) MRZ
pub global ID_CARD_MRZ_BIRTHDATE_INDEX: u32 = 30;
// Index for the document number in the MRZ
pub global ID_CARD_MRZ_DOCUMENT_NUMBER_INDEX: u32 = 5;
// Index for the document type in the MRZ
pub global ID_CARD_MRZ_DOCUMENT_TYPE_INDEX: u32 = 0;
// Index for the name of the passport holder
pub global ID_CARD_MRZ_NAME_INDEX: u32 = 60;
// Length of the MRZ on an ID card
pub global ID_CARD_MRZ_LENGTH: u32 = 90;

// ECDSA curves mapping
pub global ECDSA_CURVE_P256: u32 = 0;
pub global ECDSA_CURVE_P384: u32 = 1;
pub global ECDSA_CURVE_P521: u32 = 2;
pub global ECDSA_CURVE_BRAINPOOL_B256R1: u32 = 3;
pub global ECDSA_CURVE_BRAINPOOL_B256T1: u32 = 4;
pub global ECDSA_CURVE_BRAINPOOL_B384R1: u32 = 5;
pub global ECDSA_CURVE_BRAINPOOL_B384T1: u32 = 6;
pub global ECDSA_CURVE_BRAINPOOL_B512R1: u32 = 7;
pub global ECDSA_CURVE_BRAINPOOL_B512T1: u32 = 8;

// Proof type to identify the circuit used for a given parameter commitment
pub global PROOF_TYPE_DISCLOSE: u8 = 0;
pub global PROOF_TYPE_AGE: u8 = 1;
pub global PROOF_TYPE_BIRTHDATE: u8 = 2;
pub global PROOF_TYPE_EXPIRY_DATE: u8 = 3;
pub global PROOF_TYPE_NATIONALITY_INCLUSION: u8 = 4;
pub global PROOF_TYPE_NATIONALITY_EXCLUSION: u8 = 5;
pub global PROOF_TYPE_ISSUING_COUNTRY_INCLUSION: u8 = 6;
pub global PROOF_TYPE_ISSUING_COUNTRY_EXCLUSION: u8 = 7;
pub global PROOF_TYPE_BIND: u8 = 8;

// D<<
global GERMANY_PASSPORT_CODE: [u8; 3] = [68, 60, 60];
// DEU
global GERMANY_ISO_CODE: [u8; 3] = [68, 69, 85];

pub struct IDData {
    // Regroups the hashes of all the data groups plus some padding
    // at the start and in between each data group hashes
    pub e_content: [u8; 700],
    pub e_content_size: u32,
    // Where we can find e_content in the signed_attributes
    // It varies from document to document according to the length
    // of the padding at the start
    pub dg1_offset_in_e_content: u32,
    // Last 32 bytes: result of the hash of all the hashes of the data groups
    // Rest of the bytes: information about the signature algorithm, date, etc.
    pub signed_attributes: [u8; 200],
    pub signed_attributes_size: u32,
    // The DG1 contains the Machine Readable Zone (MRZ) of the document
    // The two lines at the bottom of the passport data page
    // or the three bottom lines on the rear of an ID card
    // 95 bytes for passports, 93 bytes for ID cards
    // Including 88 bytes of MRZ and 5 bytes of padding for passports
    // and 90 bytes of MRZ and 5 bytes of padding for ID cards
    pub dg1: [u8; 95],
    // The signature over the data groups
    pub sod_signature: [u8; 512],
    pub sod_signature_size: u32,
}

pub struct DSCData {
    // The TBS certificate of the DSC
    // TBS stands for To Be Signed
    pub tbs_certificate: [u8; 1500],
    pub tbs_certificate_size: u32,
    // The public key of the DSC (up to 512 bytes to account for RSA-4096)
    pub pubkey: [u8; 512],
    // The actual size of the public key
    pub pubkey_size: u32,
    // The index of the public key in the TBS certificate
    pub pubkey_index: u32,
    // Data used to verify the signature
    // Generated by the pre-compute function in Rust
    // c.f. main.rs
    pub pubkey_redc_param: [u8; 513],
    // The signature over the TBS certificate
    pub signature: [u8; 512],
    pub signature_size: u32,
    // The exponent of the public key
    // Only useful for RSA, can be ignored for ECDSA
    pub exponent: u32,
}

pub struct CSCData {
    // The public key of the CSC (up to 512 bytes to account for RSA-4096)
    pub pubkey: [u8; 512],
    // The actual size of the public key
    pub pubkey_size: u32,
    // Data used to verify the signature
    // Generated by the pre-compute function in Rust
    // c.f. main.rs
    pub pubkey_redc_param: [u8; 513],
    // Only useful for RSA, can be ignored for ECDSA
    pub exponent: u32,
}

pub struct DiscloseFlags {
    pub issuing_country: bool,
    pub nationality: bool,
    pub document_type: bool,
    pub document_number: bool,
    pub date_of_expiry: bool,
    pub date_of_birth: bool,
    pub gender: bool,
    pub name: bool,
}

pub struct DisclosedData {
    pub issuing_country: [u8; 3],
    pub nationality: [u8; 3],
    pub document_type: [u8; 2],
    pub document_number: [u8; 9],
    pub date_of_expiry: [u8; 6],
    pub date_of_birth: [u8; 6],
    pub name: [u8; 39],
    pub gender: [u8; 1],
}

pub fn get_array_slice<let N: u32, let M: u32>(arr: [u8; N], start: u32, end: u32) -> [u8; M] {
    let mut slice = [0 as u8; M];
    for i in start..end {
        slice[i - start] = arr[i];
    }
    slice
}

pub fn get_array_slice_constant<let N: u32, let M: u32>(arr: [u8; N]) -> [u8; M] {
    let mut slice = [0 as u8; M];
    for i in 0..M {
        slice[i] = arr[i];
    }
    slice
}

// Reverse the bytes of an array so you can switch from
// big endian to little endian order and vice versa
pub fn reverse_bytes_array<let N: u32>(arr: [u8; N]) -> [u8; N] {
    let mut reversed_arr = [0 as u8; N];
    for i in 0..N {
        // Reverse
        reversed_arr[i] = arr[N - 1 - i];
    }
    reversed_arr
}

pub fn insert_into_array<let N: u32, let M: u32>(
    mut arr: [u8; N],
    sub_arr: [u8; M],
    index: u32,
) -> [u8; N] {
    for i in index..index + M {
        arr[i] = sub_arr[i - index];
    }
    arr
}

pub fn dynamic_insert_into_array<let N: u32, let M: u32>(
    mut arr: [u8; N],
    sub_arr: [u8; M],
    index: u32,
    max_size: u32,
) -> [u8; N] {
    for i in index..index + max_size {
        if i - index < M {
            arr[i] = sub_arr[i - index];
        }
    }
    arr
}

pub fn is_id_card(dg1: [u8; 95]) -> bool {
    // For passport, the last two bytes are 0
    // since the real length is 93 for passports
    // while it is 95 for ID cards
    (dg1[93] != 0) & (dg1[94] != 0)
}

pub fn pack_be_bytes_into_field<let NBytes: u32, let MAX_FIELD_SIZE: u32>(
    x: [u8; NBytes],
) -> Field {
    let mut result: Field = 0;
    for i in 0..MAX_FIELD_SIZE {
        result *= 256;
        result += x[i] as Field;
    }
    std::as_witness(result);
    result
}

pub fn pack_be_bytes_into_u128s<let NBytes: u32, let N: u32, let MAX_FIELD_SIZE: u32>(
    x: [u8; NBytes],
) -> [u128; N] {
    let mut result = [0 as u128; N];

    let mut limb: Field = 0;
    let mut k = 0;
    for _j in 0..(MAX_FIELD_SIZE - (N * MAX_FIELD_SIZE - NBytes)) {
        limb *= 256;
        limb += x[k] as Field;
        k += 1;
    }
    std::as_witness(limb);

    result[N - 1] = limb as u128;

    for i in 1..N {
        let mut limb: Field = 0;
        for _j in 0..MAX_FIELD_SIZE {
            limb *= 256;
            limb += x[k] as Field;
            k += 1;
        }
        std::as_witness(limb);
        result[N - i - 1] = limb as u128;
    }

    result
}

#[test]
fn test_pack_be_bytes_into_u128() {
    let packed1 = pack_be_bytes_into_u128s::<512, _, 15>(TEST_BYTES);
    assert(
        packed1
            == [
                0xa906a6bf52c2d3b6dcc3e53e8df2c2,
                0xa0a652bc1a96ef6fa85aaaac8a2793,
                0xd2aa634a40e786072d1a84a726ee35,
                0x20deee9d92dd32e9d1661cad3fd748,
                0x59c58bff771bcb1007ab5292034b01,
                0xb105cd7c3f8bdffffa8976a1d6712b,
                0x7f04e817f0861ba18ffdc4e9656bd2,
                0xca6ad55f4dc9e1437ae528bff4440b,
                0x0cdf23c048109f118dbc4f062526ec,
                0xc57749fc145d2a6f68c95a0bf1345a,
                0x1744b7ad88a820d428b0f1c79a6660,
                0x21a17ae68fddadbb6d54c97ecbe1e3,
                0x3596b41957a1a78af81fbe9f418d92,
                0x5398a2f749a773190f5d838013b898,
                0xef83111bf9b7819fd12b33ff682590,
                0x56989a6176dfd100ae89dd7936e9f0,
                0x4f3d7ab2e41ba2cb404c3d6cef8740,
                0xc81a370e672704f5f31450f9156d93,
                0x2c9ad440424450b81c303c51d405d3,
                0x5d3aaebc67b2ba64a2f9546349fb9e,
                0xdced3dbea6d67fe49c3f31562ffba7,
                0xa67a19f7fcecb81235e7706b20ecc4,
                0x2fb5c8f5d8ddac8df1c6917eb31bad,
                0xd9478e0dcd3f2ab125ccc6a68c4447,
                0x2ef19aff06bf67ab4226a331ffa737,
                0x5e9ea156076a09e78b919d8c5dee0f,
                0x0b427e9391893f58968fc2d96a2775,
                0x432d27b533c103f1509b4f4fc43ac7,
                0xe0e6d9598280b0aa0f2902b0aa3b3a,
                0xa04da3f98c5cfe8d4d8f9e1fb4e89c,
                0x7e463b5ebaf81c1485efeb44e634f9,
                0xae87ec4262fcfd075f5554475547a3,
                0xfb2297b7ffc0deeb3a1b27effc6b6c,
                0xd3b801cbc8e237620d8dd9adc29551,
                0x405d,
            ],
    );
}

pub fn pack_be_bytes_into_fields<let NBytes: u32, let N: u32, let MAX_FIELD_SIZE: u32>(
    x: [u8; NBytes],
) -> [Field; N] {
    let mut result = [0 as Field; N];

    let mut limb: Field = 0;
    let mut k = 0;
    for _j in 0..(MAX_FIELD_SIZE - (N * MAX_FIELD_SIZE - NBytes)) {
        limb *= 256;
        limb += x[k] as Field;
        k += 1;
    }
    std::as_witness(limb);

    result[N - 1] = limb;

    for i in 1..N {
        let mut limb: Field = 0;
        for _j in 0..MAX_FIELD_SIZE {
            limb *= 256;
            limb += x[k] as Field;
            k += 1;
        }
        std::as_witness(limb);
        result[N - i - 1] = limb;
    }

    result
}

#[test]
fn test_pack_be_bytes_into_fields() {
    let packed1 = pack_be_bytes_into_fields::<512, _, 15>(TEST_BYTES);
    assert(
        packed1
            == [
                0xa906a6bf52c2d3b6dcc3e53e8df2c2,
                0xa0a652bc1a96ef6fa85aaaac8a2793,
                0xd2aa634a40e786072d1a84a726ee35,
                0x20deee9d92dd32e9d1661cad3fd748,
                0x59c58bff771bcb1007ab5292034b01,
                0xb105cd7c3f8bdffffa8976a1d6712b,
                0x7f04e817f0861ba18ffdc4e9656bd2,
                0xca6ad55f4dc9e1437ae528bff4440b,
                0x0cdf23c048109f118dbc4f062526ec,
                0xc57749fc145d2a6f68c95a0bf1345a,
                0x1744b7ad88a820d428b0f1c79a6660,
                0x21a17ae68fddadbb6d54c97ecbe1e3,
                0x3596b41957a1a78af81fbe9f418d92,
                0x5398a2f749a773190f5d838013b898,
                0xef83111bf9b7819fd12b33ff682590,
                0x56989a6176dfd100ae89dd7936e9f0,
                0x4f3d7ab2e41ba2cb404c3d6cef8740,
                0xc81a370e672704f5f31450f9156d93,
                0x2c9ad440424450b81c303c51d405d3,
                0x5d3aaebc67b2ba64a2f9546349fb9e,
                0xdced3dbea6d67fe49c3f31562ffba7,
                0xa67a19f7fcecb81235e7706b20ecc4,
                0x2fb5c8f5d8ddac8df1c6917eb31bad,
                0xd9478e0dcd3f2ab125ccc6a68c4447,
                0x2ef19aff06bf67ab4226a331ffa737,
                0x5e9ea156076a09e78b919d8c5dee0f,
                0x0b427e9391893f58968fc2d96a2775,
                0x432d27b533c103f1509b4f4fc43ac7,
                0xe0e6d9598280b0aa0f2902b0aa3b3a,
                0xa04da3f98c5cfe8d4d8f9e1fb4e89c,
                0x7e463b5ebaf81c1485efeb44e634f9,
                0xae87ec4262fcfd075f5554475547a3,
                0xfb2297b7ffc0deeb3a1b27effc6b6c,
                0xd3b801cbc8e237620d8dd9adc29551,
                0x405d,
            ],
    );

    let packed2 = pack_be_bytes_into_fields::<512, _, 31>(TEST_BYTES);
    assert(
        packed2
            == [
                0x35a0a652bc1a96ef6fa85aaaac8a2793a906a6bf52c2d3b6dcc3e53e8df2c2,
                0x4b0120deee9d92dd32e9d1661cad3fd748d2aa634a40e786072d1a84a726ee,
                0x656bd2b105cd7c3f8bdffffa8976a1d6712b59c58bff771bcb1007ab529203,
                0x062526ecca6ad55f4dc9e1437ae528bff4440b7f04e817f0861ba18ffdc4e9,
                0xf1c79a6660c57749fc145d2a6f68c95a0bf1345a0cdf23c048109f118dbc4f,
                0x1fbe9f418d9221a17ae68fddadbb6d54c97ecbe1e31744b7ad88a820d428b0,
                0xd12b33ff6825905398a2f749a773190f5d838013b8983596b41957a1a78af8,
                0xcb404c3d6cef874056989a6176dfd100ae89dd7936e9f0ef83111bf9b7819f,
                0x50b81c303c51d405d3c81a370e672704f5f31450f9156d934f3d7ab2e41ba2,
                0xd67fe49c3f31562ffba75d3aaebc67b2ba64a2f9546349fb9e2c9ad4404244,
                0xd8ddac8df1c6917eb31bada67a19f7fcecb81235e7706b20ecc4dced3dbea6,
                0xff06bf67ab4226a331ffa737d9478e0dcd3f2ab125ccc6a68c44472fb5c8f5,
                0x7e9391893f58968fc2d96a27755e9ea156076a09e78b919d8c5dee0f2ef19a,
                0xe6d9598280b0aa0f2902b0aa3b3a432d27b533c103f1509b4f4fc43ac70b42,
                0x7e463b5ebaf81c1485efeb44e634f9a04da3f98c5cfe8d4d8f9e1fb4e89ce0,
                0x51fb2297b7ffc0deeb3a1b27effc6b6cae87ec4262fcfd075f5554475547a3,
                0x405dd3b801cbc8e237620d8dd9adc295,
            ],
    );
}

pub fn get_mrz_from_dg1(dg1: [u8; 95]) -> [u8; 90] {
    let mut mrz = [0 as u8; 90];
    for i in 0..90 {
        mrz[i] = dg1[i + 5];
    }
    mrz
}

pub fn split_array<let N: u32>(array: [u8; N * 2]) -> ([u8; N], [u8; N]) {
    let mut array_x = [0 as u8; N];
    let mut array_y = [0 as u8; N];
    for i in 0..N {
        array_x[i] = array[i];
        array_y[i] = array[i + N];
    }
    (array_x, array_y)
}

pub fn concat_array<let N: u32>(array_x: [u8; N], array_y: [u8; N]) -> [u8; N * 2] {
    let mut array = [0 as u8; N * 2];
    for i in 0..N {
        array[i] = array_x[i];
        array[i + N] = array_y[i];
    }
    array
}

pub fn check_zero_padding<let N: u32, T>(padded_array: [T; N], len: u32)
where
    T: Eq,
    T: Default,
{
    for i in 0..N {
        if i >= len {
            assert_eq(padded_array[i], T::default());
        }
    }
}

pub fn get_nationality_from_mrz(dg1: [u8; 95]) -> [u8; 3] {
    let mrz = get_mrz_from_dg1(dg1);

    let mut country_bytes: [u8; 3] = [0; 3];

    if is_id_card(dg1) {
        country_bytes = get_array_slice(
            mrz,
            ID_CARD_MRZ_NATIONALITY_INDEX,
            ID_CARD_MRZ_NATIONALITY_INDEX + 3,
        );
    } else {
        country_bytes = get_array_slice(
            mrz,
            PASSPORT_MRZ_NATIONALITY_INDEX,
            PASSPORT_MRZ_NATIONALITY_INDEX + 3,
        );
    }

    // Handle the special case of Germany
    if (country_bytes == GERMANY_PASSPORT_CODE) {
        country_bytes = GERMANY_ISO_CODE;
    }

    country_bytes
}

pub fn get_issuing_country_from_mrz(dg1: [u8; 95]) -> [u8; 3] {
    let mrz = get_mrz_from_dg1(dg1);
    // No need to check if it's an ID card since the issuing country
    // is always at the same index for both passports and ID cards
    let mut country_bytes = get_array_slice(
        mrz,
        PASSPORT_MRZ_COUNTRY_INDEX,
        PASSPORT_MRZ_COUNTRY_INDEX + 3,
    );

    // Handle the special case of Germany
    if (country_bytes == GERMANY_PASSPORT_CODE) {
        country_bytes = GERMANY_ISO_CODE;
    }

    country_bytes
}

global TEST_BYTES: [u8; 512] = [
    0x40, 0x5d, 0xd3, 0xb8, 0x01, 0xcb, 0xc8, 0xe2, 0x37, 0x62, 0x0d, 0x8d, 0xd9, 0xad, 0xc2, 0x95,
    0x51, 0xfb, 0x22, 0x97, 0xb7, 0xff, 0xc0, 0xde, 0xeb, 0x3a, 0x1b, 0x27, 0xef, 0xfc, 0x6b, 0x6c,
    0xae, 0x87, 0xec, 0x42, 0x62, 0xfc, 0xfd, 0x07, 0x5f, 0x55, 0x54, 0x47, 0x55, 0x47, 0xa3, 0x7e,
    0x46, 0x3b, 0x5e, 0xba, 0xf8, 0x1c, 0x14, 0x85, 0xef, 0xeb, 0x44, 0xe6, 0x34, 0xf9, 0xa0, 0x4d,
    0xa3, 0xf9, 0x8c, 0x5c, 0xfe, 0x8d, 0x4d, 0x8f, 0x9e, 0x1f, 0xb4, 0xe8, 0x9c, 0xe0, 0xe6, 0xd9,
    0x59, 0x82, 0x80, 0xb0, 0xaa, 0x0f, 0x29, 0x02, 0xb0, 0xaa, 0x3b, 0x3a, 0x43, 0x2d, 0x27, 0xb5,
    0x33, 0xc1, 0x03, 0xf1, 0x50, 0x9b, 0x4f, 0x4f, 0xc4, 0x3a, 0xc7, 0x0b, 0x42, 0x7e, 0x93, 0x91,
    0x89, 0x3f, 0x58, 0x96, 0x8f, 0xc2, 0xd9, 0x6a, 0x27, 0x75, 0x5e, 0x9e, 0xa1, 0x56, 0x07, 0x6a,
    0x09, 0xe7, 0x8b, 0x91, 0x9d, 0x8c, 0x5d, 0xee, 0x0f, 0x2e, 0xf1, 0x9a, 0xff, 0x06, 0xbf, 0x67,
    0xab, 0x42, 0x26, 0xa3, 0x31, 0xff, 0xa7, 0x37, 0xd9, 0x47, 0x8e, 0x0d, 0xcd, 0x3f, 0x2a, 0xb1,
    0x25, 0xcc, 0xc6, 0xa6, 0x8c, 0x44, 0x47, 0x2f, 0xb5, 0xc8, 0xf5, 0xd8, 0xdd, 0xac, 0x8d, 0xf1,
    0xc6, 0x91, 0x7e, 0xb3, 0x1b, 0xad, 0xa6, 0x7a, 0x19, 0xf7, 0xfc, 0xec, 0xb8, 0x12, 0x35, 0xe7,
    0x70, 0x6b, 0x20, 0xec, 0xc4, 0xdc, 0xed, 0x3d, 0xbe, 0xa6, 0xd6, 0x7f, 0xe4, 0x9c, 0x3f, 0x31,
    0x56, 0x2f, 0xfb, 0xa7, 0x5d, 0x3a, 0xae, 0xbc, 0x67, 0xb2, 0xba, 0x64, 0xa2, 0xf9, 0x54, 0x63,
    0x49, 0xfb, 0x9e, 0x2c, 0x9a, 0xd4, 0x40, 0x42, 0x44, 0x50, 0xb8, 0x1c, 0x30, 0x3c, 0x51, 0xd4,
    0x05, 0xd3, 0xc8, 0x1a, 0x37, 0x0e, 0x67, 0x27, 0x04, 0xf5, 0xf3, 0x14, 0x50, 0xf9, 0x15, 0x6d,
    0x93, 0x4f, 0x3d, 0x7a, 0xb2, 0xe4, 0x1b, 0xa2, 0xcb, 0x40, 0x4c, 0x3d, 0x6c, 0xef, 0x87, 0x40,
    0x56, 0x98, 0x9a, 0x61, 0x76, 0xdf, 0xd1, 0x00, 0xae, 0x89, 0xdd, 0x79, 0x36, 0xe9, 0xf0, 0xef,
    0x83, 0x11, 0x1b, 0xf9, 0xb7, 0x81, 0x9f, 0xd1, 0x2b, 0x33, 0xff, 0x68, 0x25, 0x90, 0x53, 0x98,
    0xa2, 0xf7, 0x49, 0xa7, 0x73, 0x19, 0x0f, 0x5d, 0x83, 0x80, 0x13, 0xb8, 0x98, 0x35, 0x96, 0xb4,
    0x19, 0x57, 0xa1, 0xa7, 0x8a, 0xf8, 0x1f, 0xbe, 0x9f, 0x41, 0x8d, 0x92, 0x21, 0xa1, 0x7a, 0xe6,
    0x8f, 0xdd, 0xad, 0xbb, 0x6d, 0x54, 0xc9, 0x7e, 0xcb, 0xe1, 0xe3, 0x17, 0x44, 0xb7, 0xad, 0x88,
    0xa8, 0x20, 0xd4, 0x28, 0xb0, 0xf1, 0xc7, 0x9a, 0x66, 0x60, 0xc5, 0x77, 0x49, 0xfc, 0x14, 0x5d,
    0x2a, 0x6f, 0x68, 0xc9, 0x5a, 0x0b, 0xf1, 0x34, 0x5a, 0x0c, 0xdf, 0x23, 0xc0, 0x48, 0x10, 0x9f,
    0x11, 0x8d, 0xbc, 0x4f, 0x06, 0x25, 0x26, 0xec, 0xca, 0x6a, 0xd5, 0x5f, 0x4d, 0xc9, 0xe1, 0x43,
    0x7a, 0xe5, 0x28, 0xbf, 0xf4, 0x44, 0x0b, 0x7f, 0x04, 0xe8, 0x17, 0xf0, 0x86, 0x1b, 0xa1, 0x8f,
    0xfd, 0xc4, 0xe9, 0x65, 0x6b, 0xd2, 0xb1, 0x05, 0xcd, 0x7c, 0x3f, 0x8b, 0xdf, 0xff, 0xfa, 0x89,
    0x76, 0xa1, 0xd6, 0x71, 0x2b, 0x59, 0xc5, 0x8b, 0xff, 0x77, 0x1b, 0xcb, 0x10, 0x07, 0xab, 0x52,
    0x92, 0x03, 0x4b, 0x01, 0x20, 0xde, 0xee, 0x9d, 0x92, 0xdd, 0x32, 0xe9, 0xd1, 0x66, 0x1c, 0xad,
    0x3f, 0xd7, 0x48, 0xd2, 0xaa, 0x63, 0x4a, 0x40, 0xe7, 0x86, 0x07, 0x2d, 0x1a, 0x84, 0xa7, 0x26,
    0xee, 0x35, 0xa0, 0xa6, 0x52, 0xbc, 0x1a, 0x96, 0xef, 0x6f, 0xa8, 0x5a, 0xaa, 0xac, 0x8a, 0x27,
    0x93, 0xa9, 0x06, 0xa6, 0xbf, 0x52, 0xc2, 0xd3, 0xb6, 0xdc, 0xc3, 0xe5, 0x3e, 0x8d, 0xf2, 0xc2,
];
