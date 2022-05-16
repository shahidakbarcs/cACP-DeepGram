import org.datavec.api.records.reader.RecordReader;
import org.datavec.api.records.reader.impl.csv.CSVRecordReader;
import org.datavec.api.split.FileSplit;
import org.datavec.api.util.ClassPathResource;
import org.deeplearning4j.datasets.datavec.RecordReaderDataSetIterator;
import org.deeplearning4j.eval.Evaluation;
import org.deeplearning4j.nn.api.OptimizationAlgorithm;
import org.deeplearning4j.nn.conf.MultiLayerConfiguration;
import org.deeplearning4j.nn.conf.NeuralNetConfiguration;
import org.deeplearning4j.nn.conf.Updater;
import org.deeplearning4j.nn.conf.layers.DenseLayer;
import org.deeplearning4j.nn.conf.layers.OutputLayer;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.nn.weights.WeightInit;
import org.nd4j.linalg.activations.Activation;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.dataset.DataSet;
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator;
import org.nd4j.linalg.dataset.api.iterator.KFoldIterator;
import org.nd4j.linalg.dataset.api.preprocessor.DataNormalization;
import org.nd4j.linalg.dataset.api.preprocessor.NormalizerStandardize;
import org.nd4j.linalg.learning.config.Nesterovs;
import org.nd4j.linalg.learning.config.Sgd;
import org.nd4j.linalg.lossfunctions.LossFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.Arrays;

// author Salman Khan

public class iHBPDeepPSSM {

    public static void main(String[] args) throws Exception {  
        int numLinesToSkip = 0;
        char delimiter = ',';
		int labelIndex = 26, numClasses = 2, batchSize = 844;
		int numInputs = 100, outputNum = 2, k_fold=10;
        long seed = 1234l;
        double acc[] = new double[10];
        RecordReader recordReader = new CSVRecordReader(numLinesToSkip, delimiter);
        recordReader.initialize(new FileSplit(new ClassPathResource("ACP_Features.txt").getFile()));
        DataSetIterator iterator = new RecordReaderDataSetIterator(recordReader, batchSize, labelIndex, numClasses);
        DataSet allData = iterator.next();
        allData.shuffle();
        KFoldIterator kf = new KFoldIterator(k_fold, allData);
        for (int i = 0; i < 10; i++) {
            DataSet trainingData = kf.next();
            DataSet testData = kf.testFold();
            DataNormalization normalizer = new NormalizerStandardize();
            normalizer.fit(trainingData);           
            normalizer.transform(trainingData);     
            normalizer.transform(testData);        
            log.info("Fold...." + i);
            MultiLayerConfiguration conf = new NeuralNetConfiguration.Builder()
                .seed(seed)
                .weightInit(WeightInit.XAVIER)
                .updater(Updater.ADAGRAD)
                updater(new Nadam())
                .activation(Activation.TANH)
                .optimizationAlgo(OptimizationAlgorithm.STOCHASTIC_GRADIENT_DESCENT)
                .updater(new Nesterovs(0.9))   //momentum 0.9
                .updater(new Sgd(0.1))
                .l2(1e-4)
                .list()
                .layer(0, new DenseLayer.Builder().nIn(numInputs).nOut(24).build())
                .layer(1, new DenseLayer.Builder().nIn(24).nOut(17).build())
                .layer(2, new DenseLayer.Builder().nIn(17).nOut(12).build())
                .layer(3, new DenseLayer.Builder().nIn(12).nOut(8).build())
                .layer(4, new OutputLayer.Builder().nIn(8).nOut(outputNum)
                    .lossFunction(LossFunctions.LossFunction.NEGATIVELOGLIKELIHOOD)
                    .activation(Activation.SOFTMAX)
                    .build())
                .pretrain(false).backprop(true)
                .build();
            MultiLayerNetwork model = new MultiLayerNetwork(conf);
            model.init();
            model.setListeners(new ScoreIterationListener(100));
            for (int j = 0; j < 500; j++) 
			{
                model.fit(trainingData);
            }
            Evaluation eval = new Evaluation(2);
            INDArray output = model.output(testData.getFeatures());
            eval.eval(testData.getLabels(), output);
            acc[i] = eval.accuracy();
			}
        log.info("===================================================");
        double sum = Arrays.stream(acc).sum();
        log.info("Accuracy = " + sum /10 );
        log.info("===================================================");
    }
}
