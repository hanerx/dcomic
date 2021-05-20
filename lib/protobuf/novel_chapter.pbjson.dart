///
//  Generated code. Do not modify.
//  source: novel_chapter.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use novelChapterResponseDescriptor instead')
const NovelChapterResponse$json = const {
  '1': 'NovelChapterResponse',
  '2': const [
    const {'1': 'Errno', '3': 1, '4': 1, '5': 5, '10': 'Errno'},
    const {'1': 'Errmsg', '3': 2, '4': 1, '5': 9, '10': 'Errmsg'},
    const {'1': 'Data', '3': 3, '4': 3, '5': 11, '6': '.dmzj.novel.NovelChapterVolumeResponse', '10': 'Data'},
  ],
};

/// Descriptor for `NovelChapterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List novelChapterResponseDescriptor = $convert.base64Decode('ChROb3ZlbENoYXB0ZXJSZXNwb25zZRIUCgVFcnJubxgBIAEoBVIFRXJybm8SFgoGRXJybXNnGAIgASgJUgZFcnJtc2cSOgoERGF0YRgDIAMoCzImLmRtemoubm92ZWwuTm92ZWxDaGFwdGVyVm9sdW1lUmVzcG9uc2VSBERhdGE=');
@$core.Deprecated('Use novelChapterVolumeResponseDescriptor instead')
const NovelChapterVolumeResponse$json = const {
  '1': 'NovelChapterVolumeResponse',
  '2': const [
    const {'1': 'VolumeId', '3': 1, '4': 1, '5': 5, '10': 'VolumeId'},
    const {'1': 'VolumeName', '3': 2, '4': 1, '5': 9, '10': 'VolumeName'},
    const {'1': 'VolumeOrder', '3': 3, '4': 1, '5': 5, '10': 'VolumeOrder'},
    const {'1': 'Chapters', '3': 4, '4': 3, '5': 11, '6': '.dmzj.novel.NovelChapterItemResponse', '10': 'Chapters'},
  ],
};

/// Descriptor for `NovelChapterVolumeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List novelChapterVolumeResponseDescriptor = $convert.base64Decode('ChpOb3ZlbENoYXB0ZXJWb2x1bWVSZXNwb25zZRIaCghWb2x1bWVJZBgBIAEoBVIIVm9sdW1lSWQSHgoKVm9sdW1lTmFtZRgCIAEoCVIKVm9sdW1lTmFtZRIgCgtWb2x1bWVPcmRlchgDIAEoBVILVm9sdW1lT3JkZXISQAoIQ2hhcHRlcnMYBCADKAsyJC5kbXpqLm5vdmVsLk5vdmVsQ2hhcHRlckl0ZW1SZXNwb25zZVIIQ2hhcHRlcnM=');
@$core.Deprecated('Use novelChapterItemResponseDescriptor instead')
const NovelChapterItemResponse$json = const {
  '1': 'NovelChapterItemResponse',
  '2': const [
    const {'1': 'ChapterId', '3': 1, '4': 1, '5': 5, '10': 'ChapterId'},
    const {'1': 'ChapterName', '3': 2, '4': 1, '5': 9, '10': 'ChapterName'},
    const {'1': 'ChapterOrder', '3': 3, '4': 1, '5': 5, '10': 'ChapterOrder'},
  ],
};

/// Descriptor for `NovelChapterItemResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List novelChapterItemResponseDescriptor = $convert.base64Decode('ChhOb3ZlbENoYXB0ZXJJdGVtUmVzcG9uc2USHAoJQ2hhcHRlcklkGAEgASgFUglDaGFwdGVySWQSIAoLQ2hhcHRlck5hbWUYAiABKAlSC0NoYXB0ZXJOYW1lEiIKDENoYXB0ZXJPcmRlchgDIAEoBVIMQ2hhcHRlck9yZGVy');
@$core.Deprecated('Use novelDetailResponseDescriptor instead')
const NovelDetailResponse$json = const {
  '1': 'NovelDetailResponse',
  '2': const [
    const {'1': 'Errno', '3': 1, '4': 1, '5': 5, '10': 'Errno'},
    const {'1': 'Errmsg', '3': 2, '4': 1, '5': 9, '10': 'Errmsg'},
    const {'1': 'Data', '3': 3, '4': 1, '5': 11, '6': '.dmzj.novel.NovelDetailInfoResponse', '10': 'Data'},
  ],
};

/// Descriptor for `NovelDetailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List novelDetailResponseDescriptor = $convert.base64Decode('ChNOb3ZlbERldGFpbFJlc3BvbnNlEhQKBUVycm5vGAEgASgFUgVFcnJubxIWCgZFcnJtc2cYAiABKAlSBkVycm1zZxI3CgREYXRhGAMgASgLMiMuZG16ai5ub3ZlbC5Ob3ZlbERldGFpbEluZm9SZXNwb25zZVIERGF0YQ==');
@$core.Deprecated('Use novelDetailInfoResponseDescriptor instead')
const NovelDetailInfoResponse$json = const {
  '1': 'NovelDetailInfoResponse',
  '2': const [
    const {'1': 'NovelId', '3': 1, '4': 1, '5': 5, '10': 'NovelId'},
    const {'1': 'Name', '3': 2, '4': 1, '5': 9, '10': 'Name'},
    const {'1': 'Zone', '3': 3, '4': 1, '5': 9, '10': 'Zone'},
    const {'1': 'Status', '3': 4, '4': 1, '5': 9, '10': 'Status'},
    const {'1': 'LastUpdateVolumeName', '3': 5, '4': 1, '5': 9, '10': 'LastUpdateVolumeName'},
    const {'1': 'LastUpdateChapterName', '3': 6, '4': 1, '5': 9, '10': 'LastUpdateChapterName'},
    const {'1': 'LastUpdateVolumeId', '3': 7, '4': 1, '5': 5, '10': 'LastUpdateVolumeId'},
    const {'1': 'LastUpdateChapterId', '3': 8, '4': 1, '5': 5, '10': 'LastUpdateChapterId'},
    const {'1': 'LastUpdateTime', '3': 9, '4': 1, '5': 3, '10': 'LastUpdateTime'},
    const {'1': 'Cover', '3': 10, '4': 1, '5': 9, '10': 'Cover'},
    const {'1': 'HotHits', '3': 11, '4': 1, '5': 5, '10': 'HotHits'},
    const {'1': 'Introduction', '3': 12, '4': 1, '5': 9, '10': 'Introduction'},
    const {'1': 'Types', '3': 13, '4': 3, '5': 9, '10': 'Types'},
    const {'1': 'Authors', '3': 14, '4': 1, '5': 9, '10': 'Authors'},
    const {'1': 'FirstLetter', '3': 15, '4': 1, '5': 9, '10': 'FirstLetter'},
    const {'1': 'SubscribeNum', '3': 16, '4': 1, '5': 5, '10': 'SubscribeNum'},
    const {'1': 'RedisUpdateTime', '3': 17, '4': 1, '5': 3, '10': 'RedisUpdateTime'},
    const {'1': 'Volume', '3': 18, '4': 3, '5': 11, '6': '.dmzj.novel.NovelDetailInfoVolumeResponse', '10': 'Volume'},
  ],
};

/// Descriptor for `NovelDetailInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List novelDetailInfoResponseDescriptor = $convert.base64Decode('ChdOb3ZlbERldGFpbEluZm9SZXNwb25zZRIYCgdOb3ZlbElkGAEgASgFUgdOb3ZlbElkEhIKBE5hbWUYAiABKAlSBE5hbWUSEgoEWm9uZRgDIAEoCVIEWm9uZRIWCgZTdGF0dXMYBCABKAlSBlN0YXR1cxIyChRMYXN0VXBkYXRlVm9sdW1lTmFtZRgFIAEoCVIUTGFzdFVwZGF0ZVZvbHVtZU5hbWUSNAoVTGFzdFVwZGF0ZUNoYXB0ZXJOYW1lGAYgASgJUhVMYXN0VXBkYXRlQ2hhcHRlck5hbWUSLgoSTGFzdFVwZGF0ZVZvbHVtZUlkGAcgASgFUhJMYXN0VXBkYXRlVm9sdW1lSWQSMAoTTGFzdFVwZGF0ZUNoYXB0ZXJJZBgIIAEoBVITTGFzdFVwZGF0ZUNoYXB0ZXJJZBImCg5MYXN0VXBkYXRlVGltZRgJIAEoA1IOTGFzdFVwZGF0ZVRpbWUSFAoFQ292ZXIYCiABKAlSBUNvdmVyEhgKB0hvdEhpdHMYCyABKAVSB0hvdEhpdHMSIgoMSW50cm9kdWN0aW9uGAwgASgJUgxJbnRyb2R1Y3Rpb24SFAoFVHlwZXMYDSADKAlSBVR5cGVzEhgKB0F1dGhvcnMYDiABKAlSB0F1dGhvcnMSIAoLRmlyc3RMZXR0ZXIYDyABKAlSC0ZpcnN0TGV0dGVyEiIKDFN1YnNjcmliZU51bRgQIAEoBVIMU3Vic2NyaWJlTnVtEigKD1JlZGlzVXBkYXRlVGltZRgRIAEoA1IPUmVkaXNVcGRhdGVUaW1lEkEKBlZvbHVtZRgSIAMoCzIpLmRtemoubm92ZWwuTm92ZWxEZXRhaWxJbmZvVm9sdW1lUmVzcG9uc2VSBlZvbHVtZQ==');
@$core.Deprecated('Use novelDetailInfoVolumeResponseDescriptor instead')
const NovelDetailInfoVolumeResponse$json = const {
  '1': 'NovelDetailInfoVolumeResponse',
  '2': const [
    const {'1': 'VolumeId', '3': 1, '4': 1, '5': 5, '10': 'VolumeId'},
    const {'1': 'LnovelId', '3': 2, '4': 1, '5': 5, '10': 'LnovelId'},
    const {'1': 'VolumeName', '3': 3, '4': 1, '5': 9, '10': 'VolumeName'},
    const {'1': 'VolumeOrder', '3': 4, '4': 1, '5': 5, '10': 'VolumeOrder'},
    const {'1': 'Addtime', '3': 5, '4': 1, '5': 3, '10': 'Addtime'},
    const {'1': 'SumChapters', '3': 6, '4': 1, '5': 5, '10': 'SumChapters'},
  ],
};

/// Descriptor for `NovelDetailInfoVolumeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List novelDetailInfoVolumeResponseDescriptor = $convert.base64Decode('Ch1Ob3ZlbERldGFpbEluZm9Wb2x1bWVSZXNwb25zZRIaCghWb2x1bWVJZBgBIAEoBVIIVm9sdW1lSWQSGgoITG5vdmVsSWQYAiABKAVSCExub3ZlbElkEh4KClZvbHVtZU5hbWUYAyABKAlSClZvbHVtZU5hbWUSIAoLVm9sdW1lT3JkZXIYBCABKAVSC1ZvbHVtZU9yZGVyEhgKB0FkZHRpbWUYBSABKANSB0FkZHRpbWUSIAoLU3VtQ2hhcHRlcnMYBiABKAVSC1N1bUNoYXB0ZXJz');
