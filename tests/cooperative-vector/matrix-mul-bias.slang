// Disabled because of Vulkan validation error
//DISABLE_TEST(compute):COMPARE_COMPUTE(filecheck-buffer=CHECK):-vk -render-feature cooperative-vector -output-using-type
//TEST(compute):COMPARE_COMPUTE(filecheck-buffer=CHECK):-cpu -output-using-type

// Disabled because HLSL doesn't support int8 
//DISABLE_TEST(compute):COMPARE_COMPUTE(filecheck-buffer=CHECK):-dx12 -render-feature cooperative-vector -dx12-experimental -use-dxil -output-using-type -profile cs_6_9 -Xslang... -Xdxc -Vd -X.

// CHECK: type: int32_t
// CHECK-NEXT: 35
// CHECK-NEXT: 76
// CHECK-NEXT: 117
// CHECK-NEXT: 158

//TEST_INPUT:ubuffer(data=[0 0 0 0], stride=4):out,name=outputBuffer
RWStructuredBuffer<int32_t> outputBuffer;

//TEST_INPUT:ubuffer(data=[67305985], stride=4),name=input
//[1 2 3 4]
ByteAddressBuffer input;

//TEST_INPUT:ubuffer(data=[67305985 134678021 202050057 269422093], stride=4),name=matrix
//[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
ByteAddressBuffer matrix;

//TEST_INPUT:ubuffer(data=[5 6 7 8], stride=4),name=bias
ByteAddressBuffer bias;

[numthreads(1, 1, 1)]
void computeMain()
{
    CoopVec<int8_t, 4> vec = coopVecLoad<4, int8_t>(input);
    let result = coopVecMatMulAdd<int32_t, 4, 4>(
        vec,
        CoopVecComponentType::SignedInt8,
        matrix,
        0,
        CoopVecComponentType::SignedInt8,
        bias,
        0,
        CoopVecComponentType::SignedInt32,
        CoopVecMatrixLayout::RowMajor,
        false,
        4
    );

    for(int i = 0; i < result.getCount(); ++i)
        outputBuffer[i] = result[i];;
}
